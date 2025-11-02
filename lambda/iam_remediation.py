# Restrict risky IAM permissions
# If an IAM user has “AdministratorAccess”, it detaches that policy.
import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    user = event['detail']['resourceId']

    try:
        attached = iam.list_attached_user_policies(UserName=user)['AttachedPolicies']
        for policy in attached:
            if policy['PolicyName'] == 'AdministratorAccess':
                iam.detach_user_policy(
                    UserName=user,
                    PolicyArn=policy['PolicyArn']
                )
                print(f"Admin access removed from user {user}")
    except Exception as e:
        print(f"Error fixing IAM permissions: {e}")