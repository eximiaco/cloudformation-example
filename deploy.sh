#! /bin/bash
APPLICATION=$1
STACK=$2
REGION=${3:-us-east-1}


S3BUCKETNAME=cf-deployment-${APPLICATION}-${REGION}
PARAMETERFILE=./parameters/${STACK}.json
TEMPLATEFILE=./${STACK}.yml

PARAMETERS=$(jq -r '.[] | [.ParameterKey, .ParameterValue] | "\(.[0])=\(.[1])"' ${PARAMETERFILE})

if aws s3 ls "s3://${S3BUCKETNAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "creating deployment bucket ${S3BUCKETNAME}"
    aws s3 mb s3://${S3BUCKETNAME}
else
    echo "deployment bucket ${S3BUCKETNAME} already exists"
fi

aws cloudformation deploy \
    --template-file ${TEMPLATEFILE} \
    --stack-name ${APPLICATION}-${STACK}-stack \
    --s3-bucket ${S3BUCKETNAME} \
    --s3-prefix ${STACK} \
    --parameter-overrides ${PARAMETERS} \
    --capabilities CAPABILITY_NAMED_IAM \
    --region ${REGION}