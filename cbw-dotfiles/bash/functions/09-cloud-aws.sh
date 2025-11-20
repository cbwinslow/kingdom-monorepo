#!/usr/bin/env bash
# AWS Cloud Operations

# EC2 instances
ec2_list() {
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table
}

ec2_start() {
    aws ec2 start-instances --instance-ids "$1"
}

ec2_stop() {
    aws ec2 stop-instances --instance-ids "$1"
}

ec2_terminate() {
    aws ec2 terminate-instances --instance-ids "$1"
}

ec2_ssh() {
    local instance_id="$1"
    local ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    ssh "ubuntu@$ip"
}

ec2_ip() {
    aws ec2 describe-instances --instance-ids "$1" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
}

# S3 operations
s3_list() {
    aws s3 ls "$@"
}

s3_mb() {
    aws s3 mb "s3://$1"
}

s3_rb() {
    aws s3 rb "s3://$1" --force
}

s3_cp() {
    aws s3 cp "$1" "$2"
}

s3_sync() {
    aws s3 sync "$1" "$2"
}

s3_rm() {
    aws s3 rm "$1"
}

s3_du() {
    aws s3 ls "$1" --recursive --summarize --human-readable
}

s3_public() {
    aws s3api put-bucket-acl --bucket "$1" --acl public-read
}

s3_website() {
    aws s3 website "s3://$1" --index-document index.html --error-document error.html
}

# Lambda functions
lambda_list() {
    aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output table
}

lambda_invoke() {
    aws lambda invoke --function-name "$1" output.json && cat output.json && rm output.json
}

lambda_logs() {
    aws logs tail "/aws/lambda/$1" --follow
}

lambda_update() {
    aws lambda update-function-code --function-name "$1" --zip-file "fileb://$2"
}

# DynamoDB
dynamo_tables() {
    aws dynamodb list-tables
}

dynamo_scan() {
    aws dynamodb scan --table-name "$1"
}

dynamo_get() {
    aws dynamodb get-item --table-name "$1" --key "$2"
}

dynamo_put() {
    aws dynamodb put-item --table-name "$1" --item "$2"
}

# RDS instances
rds_list() {
    aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine,DBInstanceClass]' --output table
}

rds_start() {
    aws rds start-db-instance --db-instance-identifier "$1"
}

rds_stop() {
    aws rds stop-db-instance --db-instance-identifier "$1"
}

rds_snapshot() {
    aws rds create-db-snapshot --db-instance-identifier "$1" --db-snapshot-identifier "$2"
}

# CloudFormation
cf_list() {
    aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query 'StackSummaries[*].[StackName,StackStatus,CreationTime]' --output table
}

cf_create() {
    aws cloudformation create-stack --stack-name "$1" --template-body "file://$2"
}

cf_update() {
    aws cloudformation update-stack --stack-name "$1" --template-body "file://$2"
}

cf_delete() {
    aws cloudformation delete-stack --stack-name "$1"
}

cf_events() {
    aws cloudformation describe-stack-events --stack-name "$1" --max-items 20
}

# CloudWatch Logs
cw_groups() {
    aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output table
}

cw_tail() {
    aws logs tail "$1" --follow
}

cw_insights() {
    aws logs start-query --log-group-name "$1" --start-time $(date -u -d '1 hour ago' +%s) --end-time $(date -u +%s) --query-string "$2"
}

# IAM
iam_users() {
    aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table
}

iam_roles() {
    aws iam list-roles --query 'Roles[*].[RoleName,CreateDate]' --output table
}

iam_policies() {
    aws iam list-policies --scope Local --query 'Policies[*].[PolicyName,CreateDate]' --output table
}

iam_create_user() {
    aws iam create-user --user-name "$1"
}

iam_delete_user() {
    aws iam delete-user --user-name "$1"
}

# ECS
ecs_clusters() {
    aws ecs list-clusters
}

ecs_services() {
    aws ecs list-services --cluster "$1"
}

ecs_tasks() {
    aws ecs list-tasks --cluster "$1"
}

ecs_exec() {
    aws ecs execute-command --cluster "$1" --task "$2" --container "$3" --interactive --command "/bin/bash"
}

# EKS
eks_clusters() {
    aws eks list-clusters
}

eks_kubeconfig() {
    aws eks update-kubeconfig --name "$1"
}

eks_nodegroups() {
    aws eks list-nodegroups --cluster-name "$1"
}

# VPC
vpc_list() {
    aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
}

vpc_subnets() {
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$1" --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone]' --output table
}

# Security Groups
sg_list() {
    aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output table
}

sg_rules() {
    aws ec2 describe-security-groups --group-ids "$1" --query 'SecurityGroups[0].IpPermissions'
}

# Route53
r53_zones() {
    aws route53 list-hosted-zones --query 'HostedZones[*].[Name,Id,ResourceRecordSetCount]' --output table
}

r53_records() {
    aws route53 list-resource-record-sets --hosted-zone-id "$1"
}

# CloudFront
cf_distros() {
    aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,DomainName,Status]' --output table
}

cf_invalidate() {
    aws cloudfront create-invalidation --distribution-id "$1" --paths "/*"
}

# SNS
sns_topics() {
    aws sns list-topics
}

sns_publish() {
    aws sns publish --topic-arn "$1" --message "$2"
}

# SQS
sqs_queues() {
    aws sqs list-queues
}

sqs_send() {
    aws sqs send-message --queue-url "$1" --message-body "$2"
}

sqs_receive() {
    aws sqs receive-message --queue-url "$1"
}

sqs_purge() {
    aws sqs purge-queue --queue-url "$1"
}

# ElastiCache
elasticache_clusters() {
    aws elasticache describe-cache-clusters --query 'CacheClusters[*].[CacheClusterId,CacheNodeType,Engine,CacheClusterStatus]' --output table
}

# Secrets Manager
secrets_list() {
    aws secretsmanager list-secrets --query 'SecretList[*].[Name,Description]' --output table
}

secrets_get() {
    aws secretsmanager get-secret-value --secret-id "$1" --query 'SecretString' --output text
}

secrets_create() {
    aws secretsmanager create-secret --name "$1" --secret-string "$2"
}

# Systems Manager
ssm_parameters() {
    aws ssm describe-parameters --query 'Parameters[*].[Name,Type,LastModifiedDate]' --output table
}

ssm_get() {
    aws ssm get-parameter --name "$1" --with-decryption --query 'Parameter.Value' --output text
}

ssm_put() {
    aws ssm put-parameter --name "$1" --value "$2" --type String
}

ssm_session() {
    aws ssm start-session --target "$1"
}

# Cost Explorer
cost_today() {
    local today=$(date +%Y-%m-%d)
    aws ce get-cost-and-usage --time-period Start="$today",End="$today" --granularity DAILY --metrics "UnblendedCost"
}

cost_month() {
    local start=$(date +%Y-%m-01)
    local end=$(date +%Y-%m-%d)
    aws ce get-cost-and-usage --time-period Start="$start",End="$end" --granularity MONTHLY --metrics "UnblendedCost"
}

# AWS Profile management
aws_profile() {
    export AWS_PROFILE="$1"
    echo "Switched to AWS profile: $1"
}

aws_profiles() {
    cat ~/.aws/credentials | grep '^\[' | tr -d '[]'
}

aws_whoami() {
    aws sts get-caller-identity
}

aws_region() {
    export AWS_DEFAULT_REGION="$1"
    echo "Switched to AWS region: $1"
}

# Billing
aws_billing() {
    aws ce get-cost-and-usage --time-period Start=$(date -d 'this month' +%Y-%m-01),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics UnblendedCost
}

# AMI
ami_list() {
    aws ec2 describe-images --owners self --query 'Images[*].[ImageId,Name,CreationDate]' --output table
}

ami_create() {
    aws ec2 create-image --instance-id "$1" --name "$2"
}

# EBS Volumes
ebs_volumes() {
    aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,Size,State,VolumeType]' --output table
}

ebs_snapshot() {
    aws ec2 create-snapshot --volume-id "$1" --description "$2"
}

# Elastic Beanstalk
eb_apps() {
    aws elasticbeanstalk describe-applications --query 'Applications[*].[ApplicationName,DateCreated]' --output table
}

eb_envs() {
    aws elasticbeanstalk describe-environments --application-name "$1" --query 'Environments[*].[EnvironmentName,Status,Health]' --output table
}

# API Gateway
apigw_apis() {
    aws apigateway get-rest-apis --query 'items[*].[id,name,createdDate]' --output table
}

# Step Functions
sfn_machines() {
    aws stepfunctions list-state-machines --query 'stateMachines[*].[name,status,creationDate]' --output table
}

sfn_start() {
    aws stepfunctions start-execution --state-machine-arn "$1" --input "$2"
}
