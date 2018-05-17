package tdl.datapoint.coverage;

import com.amazonaws.services.lambda.runtime.Context;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.*;
import org.junit.contrib.java.lang.system.EnvironmentVariables;
import org.junit.rules.TemporaryFolder;
import org.yaml.snakeyaml.Yaml;
import tdl.datapoint.coverage.support.LocalS3Bucket;
import tdl.datapoint.coverage.support.LocalSQSQueue;
import tdl.datapoint.coverage.support.TestSrcsFile;
import tdl.participant.queue.connector.EventProcessingException;
import tdl.participant.queue.connector.QueueEventHandlers;
import tdl.participant.queue.connector.SqsEventQueue;
import tdl.participant.queue.events.CoverageComputedEvent;
import tdl.participant.queue.events.ProgrammingLanguageDetectedEvent;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

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
    private LocalS3Bucket localS3Bucket;
    private Stack<CoverageComputedEvent> coverageComputedEvents;
    private Stack<ProgrammingLanguageDetectedEvent> languageDetectedEvents;

    @Before
    public void setUp() throws EventProcessingException, IOException {
        setEnvFrom(Paths.get("config", "env.local.yml"));

        localS3Bucket = LocalS3Bucket.createInstance(
                getEnv(ApplicationEnv.S3_ENDPOINT),
                getEnv(ApplicationEnv.S3_REGION),
                getEnv(ApplicationEnv.S3_ACCESS_KEY),
                getEnv(ApplicationEnv.S3_SECRET_KEY));

        sqsEventQueue = LocalSQSQueue.createInstance(
                getEnv(ApplicationEnv.SQS_ENDPOINT),
                getEnv(ApplicationEnv.SQS_REGION),
                getEnv(ApplicationEnv.SQS_ACCESS_KEY),
                getEnv(ApplicationEnv.SQS_SECRET_KEY),
                getEnv(ApplicationEnv.SQS_QUEUE_URL));

        coverageUploadHandler = new CoverageUploadHandler();

        QueueEventHandlers queueEventHandlers = new QueueEventHandlers();
        coverageComputedEvents = new Stack<>();
        queueEventHandlers.on(CoverageComputedEvent.class, coverageComputedEvents::add);
        languageDetectedEvents = new Stack<>();
        queueEventHandlers.on(ProgrammingLanguageDetectedEvent.class, languageDetectedEvents::add);
        sqsEventQueue.subscribeToMessages(queueEventHandlers);
    }

    private static String getEnv(ApplicationEnv key) {
        String env = System.getenv(key.name());
        if (env == null || env.trim().isEmpty() || "null".equals(env)) {
            throw new RuntimeException("[Startup] Environment variable " + key + " not set");
        }
        return env;
    }

    private void setEnvFrom(Path path) throws IOException {
        String yamlString = Files.lines(path).collect(Collectors.joining("\n"));

        Yaml yaml = new Yaml();
        Map<String, String> values = yaml.load(yamlString);

        values.forEach((key, value) -> environmentVariables.set(key, value));
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
                convertToMap(localS3Bucket.putObject(srcs1.asFile(), s3destination)),
                NO_CONTEXT);

        // Then - Repo is created with the contents of the SRCS file
        waitForQueueToReceiveEvents();
        CoverageComputedEvent queueEvent1 = coverageComputedEvents.pop();
        String repoUrl1 = queueEvent1.getParticipant();
        assertThat(repoUrl1, allOf(startsWith("file:///"),
                containsString(challengeId),
                endsWith(participantId)));

        // When - Another upload event happens
        coverageUploadHandler.handleRequest(
                convertToMap(localS3Bucket.putObject(srcs2.asFile(), s3destination)),
                NO_CONTEXT);

        // Then - The SRCS file is appended to the repo
        waitForQueueToReceiveEvents();
        CoverageComputedEvent queueEvent2 = coverageComputedEvents.pop();
        String repoUrl2 = queueEvent2.getParticipant();
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
