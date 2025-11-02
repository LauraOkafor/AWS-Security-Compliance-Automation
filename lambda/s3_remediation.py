# handles auto-remediation for a specific service.


import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = event['detail']['requestParameters']['bucketName']
    
    # Block public access
    s3.put_public_access_block(
        Bucket=bucket_name,
        PublicAccessBlockConfiguration={
            'BlockPublicAcls': True,
            'IgnorePublicAcls': True,
            'BlockPublicPolicy': True,
            'RestrictPublicBuckets': True
        }
    )
    print(f"S3 bucket '{bucket_name}' public access blocked.")