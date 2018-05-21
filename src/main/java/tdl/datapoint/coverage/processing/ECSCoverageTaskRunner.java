package tdl.datapoint.coverage.processing;

import com.amazonaws.services.ecs.AmazonECS;
import com.amazonaws.services.ecs.model.*;

import java.util.*;
import java.util.function.Supplier;
import java.util.stream.Collectors;

public class ECSCoverageTaskRunner {
    private final String taskDefinitionPrefix;
    private AmazonECS ecsClient;
    private final Supplier<RunTaskRequest> runTaskRequestSupplier;

    public ECSCoverageTaskRunner(AmazonECS ecsClient,
                                 String cluster,
                                 String taskDefinitionPrefix,
                                 String launchType,
                                 String subnet,
                                 String securityGroup,
                                 String assignPublicIp) {
        this.ecsClient = ecsClient;
        this.taskDefinitionPrefix = taskDefinitionPrefix;

        runTaskRequestSupplier = () -> {
            RunTaskRequest runTaskRequest = new RunTaskRequest();
            runTaskRequest.setCluster(cluster);
            runTaskRequest.setTaskDefinition(ECSCoverageTaskRunner.this.taskDefinitionPrefix + "notset");
            runTaskRequest.setLaunchType(launchType);

            NetworkConfiguration networkConfiguration = new NetworkConfiguration();
            AwsVpcConfiguration awsvpcConfiguration = new AwsVpcConfiguration();
            awsvpcConfiguration.setSubnets(Collections.singletonList(subnet));
            awsvpcConfiguration.setSecurityGroups(Collections.singletonList(securityGroup));
            awsvpcConfiguration.setAssignPublicIp(assignPublicIp);

            networkConfiguration.setAwsvpcConfiguration(awsvpcConfiguration);
            runTaskRequest.setNetworkConfiguration(networkConfiguration);
            return runTaskRequest;
        };
    }

    public void runCoverageTask(String bucket, String key, Language language, String challengeId, String tag) {
        RunTaskRequest runTaskRequest = runTaskRequestSupplier.get();
        runTaskRequest.setTaskDefinition(this.taskDefinitionPrefix+language.getLanguageId());

        HashMap<String, String> env = new HashMap<>();
        env.put("REPO", "s3://" + bucket + "/" + key);
        env.put("TAG", tag);
        env.put("CHALLENGE_ID", challengeId);
        setTaskEnv(runTaskRequest, env);
        ecsClient.runTask(runTaskRequest);
    }

    private void setTaskEnv(RunTaskRequest runTaskRequest, HashMap<String, String> env) {
        TaskOverride overrides = new TaskOverride();
        ContainerOverride containerOverride = new ContainerOverride();
        List<KeyValuePair> envPairs = env.entrySet().stream().map(entry -> new KeyValuePair()
                .withName(entry.getKey()).withValue(entry.getValue())).collect(Collectors.toList());
        containerOverride.setEnvironment(envPairs);
        overrides.setContainerOverrides(Collections.singletonList(containerOverride));
        runTaskRequest.setOverrides(overrides);
    }
}
