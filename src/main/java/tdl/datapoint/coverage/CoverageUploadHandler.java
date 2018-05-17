package tdl.datapoint.coverage;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.sqs.AmazonSQS;
import com.amazonaws.services.sqs.AmazonSQSClientBuilder;
import tdl.datapoint.coverage.processing.*;
import tdl.participant.queue.connector.SqsEventQueue;
import tdl.participant.queue.events.SourceCodeUpdatedEvent;

import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import static tdl.datapoint.coverage.ApplicationEnv.*;

public class CoverageUploadHandler implements RequestHandler<Map<String, Object>, String> {
    private static final Logger LOG = Logger.getLogger(CoverageUploadHandler.class.getName());
    private AmazonS3 s3Client;
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

        srcsToGitExporter = new S3SrcsToGitExporter();

        AmazonSQS client = createSQSClient(
                getEnv(SQS_ENDPOINT),
                getEnv(SQS_REGION),
                getEnv(SQS_ACCESS_KEY),
                getEnv(SQS_SECRET_KEY)
        );

        String queueUrl = getEnv(SQS_QUEUE_URL);
        participantEventQueue = new SqsEventQueue(client, queueUrl);
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

        //TODO Implement the real logic
        S3Object remoteSRCSFile = s3Client.getObject(event.getBucket(), event.getKey());
        srcsToGitExporter.export(remoteSRCSFile, null);

        participantEventQueue.send(new SourceCodeUpdatedEvent(System.currentTimeMillis(),
                        participantId, challengeId,  null));
    }

}
