package tdl.datapoint.coverage;

import com.amazonaws.services.lambda.runtime.Context;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.*;
import org.junit.contrib.java.lang.system.EnvironmentVariables;
import org.junit.rules.TemporaryFolder;
import tdl.datapoint.coverage.support.LocalS3Bucket;
import tdl.datapoint.coverage.support.LocalSQSQueue;
import tdl.datapoint.coverage.support.TestSrcsFile;
import tdl.participant.queue.connector.EventProcessingException;
import tdl.participant.queue.connector.QueueEventHandlers;
import tdl.participant.queue.connector.SqsEventQueue;
import tdl.participant.queue.events.SourceCodeUpdatedEvent;

import java.io.IOException;
import java.util.*;

import static org.hamcrest.CoreMatchers.*;
import static org.hamcrest.MatcherAssert.assertThat;


public class CoverageDatapointAcceptanceTest {
    private static final Context NO_CONTEXT = null;

    @Rule
    public EnvironmentVariables environmentVariables = new EnvironmentVariables();

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    private CoverageUploadHandler coverageUploadHandler;
    private SqsEventQueue sqsEventQueue;
    private Stack<SourceCodeUpdatedEvent> sourceCodeUpdatedEvents;

    @Before
    public void setUp() throws EventProcessingException {
        //DEBT should read this from the `config/env.local.yml`
        env(ApplicationEnv.SQS_ENDPOINT, LocalSQSQueue.ELASTIC_MQ_URL);
        env(ApplicationEnv.SQS_REGION, LocalSQSQueue.ELASTIC_MQ_REGION);
        env(ApplicationEnv.SQS_ACCESS_KEY, LocalSQSQueue.ELASTIC_MQ_ACCESS_KEY);
        env(ApplicationEnv.SQS_SECRET_KEY, LocalSQSQueue.ELASTIC_MQ_SECRET_KEY);
        env(ApplicationEnv.SQS_QUEUE_URL, LocalSQSQueue.ELASTIC_MQ_QUEUE_URL);

        env(ApplicationEnv.S3_ENDPOINT, LocalS3Bucket.MINIO_URL);
        env(ApplicationEnv.S3_REGION, LocalS3Bucket.MINIO_REGION);
        env(ApplicationEnv.S3_ACCESS_KEY, LocalS3Bucket.MINIO_ACCESS_KEY);
        env(ApplicationEnv.S3_SECRET_KEY, LocalS3Bucket.MINIO_SECRET_KEY);

        coverageUploadHandler = new CoverageUploadHandler();

        sqsEventQueue = LocalSQSQueue.createInstance();

        QueueEventHandlers queueEventHandlers = new QueueEventHandlers();
        sourceCodeUpdatedEvents = new Stack<>();
        queueEventHandlers.on(SourceCodeUpdatedEvent.class, sourceCodeUpdatedEvents::add);
        sqsEventQueue.subscribeToMessages(queueEventHandlers);
    }

    private void env(ApplicationEnv key, String value) {
        environmentVariables.set(key.name(), value);
    }

    @After
    public void tearDown() throws Exception {
        sqsEventQueue.unsubscribeFromMessages();
    }

    @Ignore("Copied from dpnt-sourcecode")
    @Test
    public void create_repo_and_uploads_commits() throws Exception {
        // Given - The participant produces SRCS files while solving a challenge
        String challengeId = generateId();
        String participantId = generateId();
        String s3destination = String.format("%s/%s/file.srcs", challengeId, participantId);
        TestSrcsFile srcs1 = new TestSrcsFile("test1.srcs");
        TestSrcsFile srcs2 = new TestSrcsFile("test2.srcs");

        // When - Upload event happens
        coverageUploadHandler.handleRequest(
                convertToMap(LocalS3Bucket.putObject(srcs1.asFile(), s3destination)),
                NO_CONTEXT);

        // Then - Repo is created with the contents of the SRCS file
        waitForQueueToReceiveEvents();
        SourceCodeUpdatedEvent queueEvent1 = sourceCodeUpdatedEvents.pop();
        String repoUrl1 = queueEvent1.getSourceCodeLink();
        assertThat(repoUrl1, allOf(startsWith("file:///"),
                containsString(challengeId),
                endsWith(participantId)));

        // When - Another upload event happens
        coverageUploadHandler.handleRequest(
                convertToMap(LocalS3Bucket.putObject(srcs2.asFile(), s3destination)),
                NO_CONTEXT);

        // Then - The SRCS file is appended to the repo
        waitForQueueToReceiveEvents();
        SourceCodeUpdatedEvent queueEvent2 = sourceCodeUpdatedEvents.pop();
        String repoUrl2 = queueEvent2.getSourceCodeLink();
        assertThat(repoUrl1, equalTo(repoUrl2));
    }

    //~~~~~~~~~~ Helpers ~~~~~~~~~~~~~`

    private static void waitForQueueToReceiveEvents() throws InterruptedException {
        Thread.sleep(500);
    }

    private static String generateId() {
        return UUID.randomUUID().toString().replaceAll("-","");
    }

    private static Map<String, Object> convertToMap(String json) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readValue(json, new TypeReference<Map<String, Object>>() {});
    }

    private static List<String> getCombinedMessages(TestSrcsFile srcs1, TestSrcsFile srcs2) throws IOException {
        List<String> combinedList = new ArrayList<>();
        combinedList.addAll(srcs1.getCommitMessages());
        combinedList.addAll(srcs2.getCommitMessages());
        return combinedList;
    }

    private static List<String> getCombinedTags(TestSrcsFile srcs1, TestSrcsFile srcs2) throws IOException {
        List<String> combinedList = new ArrayList<>();
        combinedList.addAll(srcs1.getTags());
        combinedList.addAll(srcs2.getTags());
        return combinedList;
    }
}
