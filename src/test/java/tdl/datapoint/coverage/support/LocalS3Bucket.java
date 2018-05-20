package tdl.datapoint.coverage.support;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;

import java.io.File;

public class LocalS3Bucket {
    private final AmazonS3 s3Client;

    private LocalS3Bucket(AmazonS3 s3Client) {
        this.s3Client = s3Client;
    }

    public static LocalS3Bucket createInstance(String endpoint, String region, String accessKey, String secretKey) {
        AwsClientBuilder.EndpointConfiguration endpointConfiguration =
                new AwsClientBuilder.EndpointConfiguration(endpoint, region);
        AWSCredentials credential = new BasicAWSCredentials(accessKey, secretKey);
        AmazonS3 s3Client = AmazonS3ClientBuilder
                .standard()
                .withPathStyleAccessEnabled(true)
                .withCredentials(new AWSStaticCredentialsProvider(credential))
                .withEndpointConfiguration(endpointConfiguration)
                .build();
        return new LocalS3Bucket(s3Client);
    }

    public String putObject(File object, String key) {
        String bucket = "localbucket";
        createBucketIfNotExists(s3Client, bucket);
        s3Client.putObject(bucket, key, object);
        return String.format("{\"Records\":[{\"s3\":" +
                "{\"bucket\":{\"name\":\"%s\"}, " +
                "\"object\":{\"key\":\"%s\"}}}" +
                "]}", bucket, key);
    }

    @SuppressWarnings("deprecation")
    private void createBucketIfNotExists(AmazonS3 client, String bucket) {
        if (!client.doesBucketExist(bucket)) {
            client.createBucket(bucket);
        }
    }

}