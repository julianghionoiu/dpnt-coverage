package tdl.datapoint.coverage;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.ecs.AmazonECS;
import com.amazonaws.services.ecs.AmazonECSAsyncClientBuilder;
import com.amazonaws.services.ecs.model.RunTaskRequest;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.sqs.AmazonSQS;
import com.amazonaws.services.sqs.AmazonSQSClientBuilder;
import org.eclipse.jgit.api.Git;
import tdl.datapoint.coverage.processing.Language;
import tdl.datapoint.coverage.processing.LocalGitClient;
import tdl.datapoint.coverage.processing.S3BucketEvent;
import tdl.datapoint.coverage.processing.S3SrcsToGitExporter;
import tdl.participant.queue.connector.SqsEventQueue;
import tdl.participant.queue.events.ProgrammingLanguageDetectedEvent;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import static tdl.datapoint.coverage.ApplicationEnv.*;

public class CoverageUploadHandler implements RequestHandler<Map<String, Object>, String> {
    private static final Logger LOG = Logger.getLogger(CoverageUploadHandler.class.getName());
    private AmazonS3 s3Client;
    private AmazonECS ecsClient;
    private SqsEventQueue participantEventQueue;
    private S3SrcsToGitExporter srcsToGitExporter;

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
                getEnv(S3_REGION),
                getEnv(S3_ACCESS_KEY),
                getEnv(S3_SECRET_KEY));

        ecsClient = createECSClient(
                getEnv(ECS_ENDPOINT),
                getEnv(ECS_REGION),
                getEnv(ECS_ACCESS_KEY),
                getEnv(ECS_SECRET_KEY));

        srcsToGitExporter = new S3SrcsToGitExporter();

        AmazonSQS queueClient = createSQSClient(
                getEnv(SQS_ENDPOINT),
                getEnv(SQS_REGION),
                getEnv(SQS_ACCESS_KEY),
                getEnv(SQS_SECRET_KEY)
        );
        String queueUrl = getEnv(SQS_QUEUE_URL);
        participantEventQueue = new SqsEventQueue(queueClient, queueUrl);
    }

    private static AmazonS3 createS3Client(String endpoint, String region, String accessKey, String secretKey) {
        AmazonS3ClientBuilder builder = AmazonS3ClientBuilder.standard();
        builder = builder.withPathStyleAccessEnabled(true)
                .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration(endpoint, region))
                .withCredentials(new AWSStaticCredentialsProvider(
                        new BasicAWSCredentials(accessKey, secretKey)));
        return builder.build();
    }

    private static AmazonSQS createSQSClient(String serviceEndpoint, String signingRegion, String accessKey, String secretKey) {
        AwsClientBuilder.EndpointConfiguration endpointConfiguration =
                new AwsClientBuilder.EndpointConfiguration(serviceEndpoint, signingRegion);
        return AmazonSQSClientBuilder.standard()
                .withEndpointConfiguration(endpointConfiguration)
                .withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(accessKey, secretKey)))
                .build();
    }

    private static AmazonECS createECSClient(String serviceEndpoint, String signingRegion, String accessKey, String secretKey) {
        AwsClientBuilder.EndpointConfiguration endpointConfiguration =
                new AwsClientBuilder.EndpointConfiguration(serviceEndpoint, signingRegion);
        return AmazonECSAsyncClientBuilder.standard()
                .withEndpointConfiguration(endpointConfiguration)
                .withCredentials(new AWSStaticCredentialsProvider(new BasicAWSCredentials(accessKey, secretKey)))
                .build();
    }

    @Override
    public String handleRequest(Map<String, Object> s3EventMap, Context context) {
        try {
            handleS3Event(S3BucketEvent.from(s3EventMap));
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
        List<String> tags = LocalGitClient.getTags(localRepo);

        if (tags.isEmpty()) {
            LOG.info("No tags to process. Exiting");
            return;
        } else {
            LOG.info("Relevant tags"+tags);
        }

        LOG.info("Triggering ECS to process coverage for tags");
        for (String tag : tags) {
            RunTaskRequest runTaskRequest = new RunTaskRequest();
            runTaskRequest.setTaskDefinition("myTaskDefinition");
            runTaskRequest.setLaunchType("FARGATE");
            //TODO for each tag, call ECS with: container-image id, bucket, key, tag
            ecsClient.runTask(runTaskRequest);
        }
    }
}
