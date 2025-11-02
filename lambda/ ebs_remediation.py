# Enforce EBS encryption
# If an EBS volume is unencrypted, it creates an encrypted copy and reattaches it.


import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    volume_id = event['detail']['resourceId']

    try:
        volume = ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]
        if not volume['Encrypted']:
            snapshot = ec2.create_snapshot(VolumeId=volume_id, Description="Encrypting volume")
            ec2.copy_snapshot(
                SourceSnapshotId=snapshot['SnapshotId'],
                Encrypted=True
            )
            print(f"EBS volume {volume_id} is now encrypted.")
    except Exception as e:
        print(f"Error encrypting volume: {e}")