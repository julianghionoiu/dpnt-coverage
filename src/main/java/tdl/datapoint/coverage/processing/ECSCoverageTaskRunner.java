package tdl.datapoint.coverage.processing;

import com.amazonaws.services.ecs.AmazonECS;
import com.amazonaws.services.ecs.model.AwsVpcConfiguration;
import com.amazonaws.services.ecs.model.NetworkConfiguration;
import com.amazonaws.services.ecs.model.RunTaskRequest;

import java.util.Collections;

public class ECSCoverageTaskRunner {
    private final String taskDefinitionPrefix;
    private AmazonECS ecsClient;
    private final RunTaskRequest runTaskRequest;

    public ECSCoverageTaskRunner(AmazonECS ecsClient,
                                 String cluster,
                                 String taskDefinitionPrefix,
                                 String launchType,
                                 String subnet,
                                 String securityGroup,
                                 String assignPublicIp) {
        this.ecsClient = ecsClient;
        this.taskDefinitionPrefix = taskDefinitionPrefix;

        runTaskRequest = new RunTaskRequest();
        runTaskRequest.setCluster(cluster);
        runTaskRequest.setTaskDefinition(this.taskDefinitionPrefix +"notset");
        runTaskRequest.setLaunchType(launchType);

        NetworkConfiguration networkConfiguration = new NetworkConfiguration();
        AwsVpcConfiguration awsvpcConfiguration = new AwsVpcConfiguration();
        awsvpcConfiguration.setSubnets(Collections.singletonList(subnet));
        awsvpcConfiguration.setSecurityGroups(Collections.singletonList(securityGroup));
        awsvpcConfiguration.setAssignPublicIp(assignPublicIp);

        networkConfiguration.setAwsvpcConfiguration(awsvpcConfiguration);
        runTaskRequest.setNetworkConfiguration(networkConfiguration);
    }

    public void runCoverageTask(Language language, String tag) {
        runTaskRequest.setTaskDefinition(this.taskDefinitionPrefix+language.getLanguageId());
        ecsClient.runTask(runTaskRequest);
    }
}
