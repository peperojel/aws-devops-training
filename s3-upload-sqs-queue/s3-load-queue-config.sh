#!/bin/bash

# Configures a S3 bucket to send a message to a SNS topic when an object is stored in the bucket.

# Implementation:

PROFILE="linux-acad"
S3_BUCKET_NAME="cfst-1160-8a92f3927e55b249fe9ecba-mys3inputbucket-1k6igdraeumzc"
QUEUE_URL="https://queue.amazonaws.com/502798736944/SQSBatchQueue"
NOTIF_CONFIG_FILE="./queue-config.json"

# Check if notification config file exists.
if [[ ! -e "${NOTIF_CONFIG_FILE}" ]]
then
    echo "Cannot open notification configuration file: ${NOTIF_CONFIG_FILE}" >&2
    exit 1
fi

# Get the QueueArn.
QUEUE_ARN=$(aws sqs get-queue-attributes \
    --queue-url ${QUEUE_URL} \
    --attribute-names QueueArn \
    --profile ${PROFILE} \
    | jq '.Attributes.QueueArn')

# Replace the SQS ARN in notification-config.json
sed -i "s+<sqs-arn>+$(echo ${QUEUE_ARN})+" ${NOTIF_CONFIG_FILE}

# Set bucket's notification configuration.
aws s3api \
    put-bucket-notification-configuration \
        --bucket ${S3_BUCKET_NAME} \
        --notification-configuration file://${NOTIF_CONFIG_FILE} \
        --profile ${PROFILE}

if [[ "${?}" -ne 0 ]]; then
    echo "The notification configuration could not be loaded to ${S3_BUCKET_NAME}" >&2
    exit 1
fi

echo "The notification configuration was loaded succesfully."
exit 0