package tdl.datapoint.coverage;

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.ecs.AmazonECS;
import com.amazonaws.services.ecs.AmazonECSAsyncClientBuilder;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.sqs.AmazonSQS;
import com.amazonaws.services.sqs.AmazonSQSClientBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.eclipse.jgit.api.Git;
import tdl.datapoint.coverage.processing.*;
import tdl.participant.queue.connector.SqsEventQueue;
import tdl.participant.queue.events.ProgrammingLanguageDetectedEvent;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import static tdl.datapoint.coverage.ApplicationEnv.*;

public class CoverageUploadHandler implements RequestHandler<Map<String, Object>, String> {
    private static final Logger LOG = Logger.getLogger(CoverageUploadHandler.class.getName());
    private AmazonS3 s3Client;
    private SqsEventQueue participantEventQueue;
    private S3SrcsToGitExporter srcsToGitExporter;
    private final ECSCoverageTaskRunner ecsCoverageTaskRunner;
    private ObjectMapper jsonObjectMapper;

    private static String getEnv(ApplicationEnv key) {
        String env = System.getenv(key.name());
        if (env == null || env.trim().isEmpty() || "null".equals(env)) {
            throw new RuntimeException("[Startup] Environment variable " + key + " not set");
        }
        return env;
    }

    @SuppressWarnings("WeakerAccess")
    public CoverageUploadHandler() {
        s3Client = createS3Client(
                getEnv(S3_ENDPOINT),
                getEnv(S3_REGION));

        AmazonECS ecsClient = createECSClient(
                getEnv(ECS_ENDPOINT),
                getEnv(ECS_REGION));

        ecsCoverageTaskRunner = new ECSCoverageTaskRunner(ecsClient,
                getEnv(ECS_TASK_CLUSTER),
                getEnv(ECS_TASK_DEFINITION_PREFIX),
                getEnv(ECS_TASK_LAUNCH_TYPE),
                getEnv(ECS_VPC_SUBNET),
                getEnv(ECS_VPC_SECURITY_GROUP),
                getEnv(ECS_VPC_ASSIGN_PUBLIC_IP));

        srcsToGitExporter = new S3SrcsToGitExporter();

        AmazonSQS queueClient = createSQSClient(
                getEnv(SQS_ENDPOINT),
                getEnv(SQS_REGION)
        );
        String queueUrl = getEnv(SQS_QUEUE_URL);
        participantEventQueue = new SqsEventQueue(queueClient, queueUrl);

        jsonObjectMapper = new ObjectMapper();
    }

    private static AmazonS3 createS3Client(String endpoint, String region) {
        AmazonS3ClientBuilder builder = AmazonS3ClientBuilder.standard();
        builder = builder.withPathStyleAccessEnabled(true)
                .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(endpoint, region))
                .withCredentials(new DefaultAWSCredentialsProviderChain());
        return builder.build();
    }

    private static AmazonSQS createSQSClient(String serviceEndpoint, String signingRegion) {
        AwsClientBuilder.EndpointConfiguration endpointConfiguration =
                new AwsClientBuilder.EndpointConfiguration(serviceEndpoint, signingRegion);
        return AmazonSQSClientBuilder.standard()
                .withEndpointConfiguration(endpointConfiguration)
                .withCredentials(new DefaultAWSCredentialsProviderChain())
                .build();
    }

    private static AmazonECS createECSClient(String serviceEndpoint, String signingRegion) {
        AwsClientBuilder.EndpointConfiguration endpointConfiguration =
                new AwsClientBuilder.EndpointConfiguration(serviceEndpoint, signingRegion);
        return AmazonECSAsyncClientBuilder.standard()
                .withEndpointConfiguration(endpointConfiguration)
                .withCredentials(new DefaultAWSCredentialsProviderChain())
                .build();
    }

    @Override
    public String handleRequest(Map<String, Object> s3EventMap, Context context) {
        try {
            handleS3Event(S3BucketEvent.from(s3EventMap, jsonObjectMapper));
            return "OK";
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, ex.getMessage(), ex);
            throw new RuntimeException(ex);
        }
    }

    private void handleS3Event(S3BucketEvent event) throws Exception {
        LOG.info("Process S3 event with: "+event);
        String participantId = event.getParticipantId();
        String challengeId = event.getChallengeId();

        LOG.info("Initialise local temp repo");
        Path tempDirectory = Files.createTempDirectory(participantId);
        Git localRepo = LocalGitClient.init(tempDirectory);
        LOG.info("Local repo initialised at "+localRepo.getRepository().getDirectory());

        LOG.info("Read repo from SRCS file "+event.getKey());
        S3Object remoteSRCSFile = s3Client.getObject(event.getBucket(), event.getKey());
        srcsToGitExporter.export(remoteSRCSFile, tempDirectory);
        LOG.info("SRCS file exported to: " + tempDirectory);

        LOG.info("Identify language");
        Path languageFile = tempDirectory.resolve("language.tdl");
        String languageString = Files.lines(languageFile).findFirst()
                .orElseThrow(() -> new IllegalArgumentException("The repo provided does not have a valid `language.tdl` file"));
        Language language = Language.of(languageString);
        participantEventQueue.send(new ProgrammingLanguageDetectedEvent(System.currentTimeMillis(),
                participantId, challengeId, language.getReportedLanguageName()));
        LOG.info("Language identified as: "+language.getLanguageId());

        LOG.info("Identify \"done\" tags");
        List<String> doneTags = LocalGitClient.getTags(localRepo).stream()
                .filter(s -> s.startsWith(challengeId))
                .filter(s -> s.endsWith("/done"))
                .collect(Collectors.toList());
        if (doneTags.isEmpty()) {
            LOG.info("No tags to process. Exiting");
            return;
        } else {
            LOG.info("Relevant tags "+doneTags);
        }

        LOG.info("Triggering ECS to process coverage for tags");
        for (String doneTag : doneTags) {
            String roundId = doneTag.split("/")[0];
            ecsCoverageTaskRunner.runCoverageTask(event.getBucket(), event.getKey(),
                    participantId, challengeId, roundId, language, doneTag);
        }
    }


}
