#!/bin/bash

# This script creates a topic and subscribe an email account for automating notifications coming from a variety of AWS services.

# Definitions:

# Credentials and config for la-cad are defined in ~/.aws (see https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
PROFILE="--profile la-acad"
TOPIC_NAME="TaskStoppedAlert"
EMAIL="niyame1921@beiop.com"

# If topic already exits get its ARN.
TOPIC_ARN=$(set -o pipefail; aws sns list-topics ${PROFILE} | grep "${TOPIC_NAME}$" | awk '{print $2}')

# If not create it and get its ARN.
if [[ ${?} -ne 0 ]]
then
    TOPIC_ARN=$(aws sns create-topic --name ${TOPIC_NAME} ${PROFILE})
fi

# Subscribe your desired email account to the topic.
aws sns subscribe --topic-arn ${TOPIC_ARN}  --protocol email --notification-endpoint ${EMAIL} ${PROFILE} &> /dev/null

if [[ ${?} -ne 0 ]]
then
    echo "Subscription to ${TOPIC_NAME} failed." >&2
    exit 1
fi
  
echo "${EMAIL} was subscribed succesfully to ${TOPIC_NAME}."
exit 0


