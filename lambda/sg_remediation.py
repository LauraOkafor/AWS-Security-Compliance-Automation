# Fix overly open security groups

# Removes inbound rules that allow 0.0.0.0/0 
# (which means “open to the entire internet”).

import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    sg_id = event['detail']['resourceId']

    try:
        sg = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]
        for rule in sg['IpPermissions']:
            for ip_range in rule.get('IpRanges', []):
                if ip_range.get('CidrIp') == '0.0.0.0/0':
                    ec2.revoke_security_group_ingress(
                        GroupId=sg_id,
                        IpPermissions=[rule]
                    )
                    print(f"Removed open ingress rule from {sg_id}")
    except Exception as e:
        print(f"Error fixing security group: {e}")