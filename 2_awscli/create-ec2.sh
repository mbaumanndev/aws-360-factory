#!/usr/bin/env bash

set -e

######################################################################
# Variable definition
######################################################################

EC2_AMI_NAME="ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"
EC2_SUBNET_REGION="us-east-1b"
EC2_GROUP_NAME="ops"
EC2_INSTANCE_TYPE="t2.micro"
EC2_KEY_NAME="aws-360-factory"

######################################################################
# Get the AMI_ID
######################################################################

echo "Getting AMI Id..."
EC2_AMI_ID=$(aws ec2 describe-images \
                --filters "Name=name,Values=${EC2_AMI_NAME}" \
                --query "reverse(sort_by(Images[], &CreationDate))[0].ImageId" \
                --output text)

echo "Got AMI Id: ${EC2_AMI_ID}"

######################################################################
# Get the VPC Id
######################################################################

echo "Getting VPC Id..."
EC2_VPC_ID=$(aws ec2 describe-vpcs \
                --filters "Name=isDefault,Values=true" \
                --query "Vpcs[0].VpcId" --output text)

echo "Got VPC Id: ${EC2_VPC_ID}"

######################################################################
# Get the Subnet Id within the VPC
######################################################################

echo "Getting Subnet Id..."
EC2_SUBNET_ID=$(aws ec2 describe-subnets \
                    --filters "Name=availabilityZone,Values=${EC2_SUBNET_REGION}" \
                              "Name=vpcId,Values=${EC2_VPC_ID}" \
                    --query "Subnets[0].SubnetId" \
                    --output text)

echo "Got Subnet Id: ${EC2_SUBNET_ID}"

######################################################################
# Get the Security groups Id
######################################################################

echo "Getting Security Group Id..."
EC2_SG_ID=$(aws ec2 describe-security-groups \
                --filters "Name=vpc-id,Values=${EC2_VPC_ID}" \
                --group-names "${EC2_GROUP_NAME}" \
                --query "SecurityGroups[0].GroupId" \
                --output text)

echo "Got Security Group Id: ${EC2_SG_ID}"

######################################################################
### Provision EC2 Server
######################################################################

echo "Provisioning EC2 instance..."
EC2_PROVISION=$(aws ec2 run-instances \
                    --image-id "${EC2_AMI_ID}" \
                    --key-name "${EC2_KEY_NAME}" \
                    --instance-type "${EC2_INSTANCE_TYPE}" \
                    --security-group-ids "${EC2_SG_ID}" \
                    --subnet-id "${EC2_SUBNET_ID}" \
                    --output text)

echo "Ec2 Instance ready, here are the details:"
echo ${EC2_PROVISION}
