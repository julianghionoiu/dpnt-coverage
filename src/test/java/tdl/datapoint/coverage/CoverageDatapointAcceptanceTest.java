package tdl.datapoint.coverage;

import com.amazonaws.services.lambda.runtime.Context;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.contrib.java.lang.system.EnvironmentVariables;
import org.junit.rules.TemporaryFolder;
import org.yaml.snakeyaml.Yaml;
import tdl.datapoint.coverage.support.*;
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

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.MatcherAssert.assertThat;


public class CoverageDatapointAcceptanceTest {
    private static final Context NO_CONTEXT = null;
    private static final int WAIT_BEFORE_RETRY_IN_MILLIS = 2000;
    private static final int TASK_FINISH_CHECK_RETRY_COUNT = 10;

    @Rule
    public EnvironmentVariables environmentVariables = new EnvironmentVariables();

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    private CoverageUploadHandler coverageUploadHandler;
    private SqsEventQueue sqsEventQueue;
    private LocalS3Bucket localS3Bucket;
    private List<CoverageComputedEvent> coverageComputedEvents;
    private List<ProgrammingLanguageDetectedEvent> languageDetectedEvents;
    private ObjectMapper mapper;

    @Before
    public void setUp() throws EventProcessingException, IOException {
        environmentVariables.set("AWS_ACCESS_KEY_ID","local_test_access_key");
        environmentVariables.set("AWS_SECRET_KEY","local_test_secret_key");
        setEnvFrom(environmentVariables, Paths.get("config", "local.params.yml"));

        localS3Bucket = LocalS3Bucket.createInstance(
                getEnv(ApplicationEnv.S3_ENDPOINT),
                getEnv(ApplicationEnv.S3_REGION));

        sqsEventQueue = LocalSQSQueue.createInstance(
                getEnv(ApplicationEnv.SQS_ENDPOINT),
                getEnv(ApplicationEnv.SQS_REGION),
                getEnv(ApplicationEnv.SQS_QUEUE_URL));

        coverageUploadHandler = new CoverageUploadHandler();

        QueueEventHandlers queueEventHandlers = new QueueEventHandlers();
        coverageComputedEvents = new ArrayList<>();
        queueEventHandlers.on(CoverageComputedEvent.class, coverageComputedEvents::add);
        languageDetectedEvents = new Stack<>();
        queueEventHandlers.on(ProgrammingLanguageDetectedEvent.class, languageDetectedEvents::add);
        sqsEventQueue.subscribeToMessages(queueEventHandlers);

        mapper = new ObjectMapper();
    }

    private static String getEnv(ApplicationEnv key) {
        String env = System.getenv(key.name());
        if (env == null || env.trim().isEmpty() || "null".equals(env)) {
            throw new RuntimeException("[Startup] Environment variable " + key + " not set");
        }
        return env;
    }

    private static void setEnvFrom(EnvironmentVariables environmentVariables, Path path) throws IOException {
        String yamlString = Files.lines(path).collect(Collectors.joining("\n"));

        Yaml yaml = new Yaml();
        Map<String, String> values = yaml.load(yamlString);

        values.forEach(environmentVariables::set);
    }

    @After
    public void tearDown() throws Exception {
        sqsEventQueue.unsubscribeFromMessages();
    }

    @Test
    public void create_repo_and_uploads_commits() throws Exception {
        // Given - The participant produces SRCS files while solving a challenge
        String challengeId = "TCH";
        String participantId = generateId();
        String s3destination = String.format("%s/%s/file.srcs", challengeId, participantId);
        TestSrcsFile srcsForTestChallenge = new TestSrcsFile("HmmmLang_R1Cov33_R2Cov44.srcs");

        // When - Upload event happens
        S3Event s3Event = localS3Bucket.putObject(srcsForTestChallenge.asFile(), s3destination);
        coverageUploadHandler.handleRequest(
                convertToMap(wrapAsSNSEvent(s3Event)),
                NO_CONTEXT);
        waitForQueueToReceiveEvents();

        // Then - Language detected event should be generated for the challenge
        assertThat(languageDetectedEvents.size(), equalTo(1));
        System.out.println("Received language detected events: "+languageDetectedEvents);
        ProgrammingLanguageDetectedEvent languageEvent = languageDetectedEvents.get(0);
        assertThat(languageEvent.getParticipant(), equalTo(participantId));
        assertThat(languageEvent.getChallengeId(), equalTo(challengeId));
        assertThat(languageEvent.getProgrammingLanguage(), equalTo("HmmmLang"));

        // Then - Coverage events are computed for the deploy tags
        assertThat(coverageComputedEvents.size(), equalTo(2));
        System.out.println("Received coverage events: "+coverageComputedEvents);
        coverageComputedEvents.sort(Comparator.comparing(CoverageComputedEvent::getRoundId));
        CoverageComputedEvent coverageRound1 = coverageComputedEvents.get(0);
        assertThat(coverageRound1.getParticipant(), equalTo(participantId));
        assertThat(coverageRound1.getRoundId(), equalTo(challengeId+"_R1"));
        assertThat(coverageRound1.getCoverage(), equalTo(33));
        CoverageComputedEvent coverageRound2 = coverageComputedEvents.get(1);
        assertThat(coverageRound2.getParticipant(), equalTo(participantId));
        assertThat(coverageRound2.getRoundId(), equalTo(challengeId+"_R2"));
        assertThat(coverageRound2.getCoverage(), equalTo(44));
    }

    private String wrapAsSNSEvent(S3Event s3Event) throws JsonProcessingException {
        SNSEvent snsEvent = new SNSEvent(mapper.writeValueAsString(s3Event.asJsonNode()));
        return mapper.writeValueAsString(snsEvent.asJsonNode());
    }

    //~~~~~~~~~~ Helpers ~~~~~~~~~~~~~`

    private void waitForQueueToReceiveEvents() throws InterruptedException {
        int retryCtr = 0;
        while ((coverageComputedEvents.size() < 2) && (retryCtr < TASK_FINISH_CHECK_RETRY_COUNT)) {
            Thread.sleep(WAIT_BEFORE_RETRY_IN_MILLIS);
            retryCtr++;
        }
    }

    private static String generateId() {
        return UUID.randomUUID().toString().replaceAll("-","");
    }

    private static Map<String, Object> convertToMap(String json) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readValue(json, new TypeReference<Map<String, Object>>() {});
    }
}
