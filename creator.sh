#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0d34a14d6eba15d9d"
ZONE_ID="Z0738852208EFDOYXFTUB"
DOMAIN_NAME="opsora.space"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
C="\e[36m"
N="\e[0m"


for service in $@
do
   EXISTING_ID=$(
    aws ec2 describe-instances \
     --filters "Name=tag:Name,Values=$service" \
     "Name=instance-state-name,Values=running"
   )

   if [ -n "${EXISTING_ID}" ]; then
      INSTANCE_ID=$EXISTING_ID
      echo -e " $G ${service} instance is already present. $Y Skipping Creation.. $N "
      exit 1
   else
      if [ "$service" == "mysql" ]; then

    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.medium \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId'
    --output text)
    else 
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text
    )
    fi
fi

if [ $INSTANCE_ID == 'frontend' ]; then
    IP=$(
     aws ec2 describe-instances \
    --filters "Name=instance-id,Values=$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text
    )
    DNS_RECORD=$service.$DOMAIN_NAME

    else
    IP=$(
        aws ec2 describe-instances \
    --filters "Name=instance-id,Values=$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PrivateIpAddress' \
    --output text
    )
    DNS_RECORD=$DOMAIN_NAME
fi

aws route53 change-resource-record-sets --hosted-zone-id Z1R8UBAEXAMPLE --change-batch '

{
  "Comment": "Creating A record for ${service}",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "'${DNS_RECORD}'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
        ]
      }
    }
  ]
}

'

echo "record updated for $service"



done
