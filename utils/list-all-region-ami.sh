#!/bin/bash
if [ -z "$1" ] ; then
    echo "Please pass the image filter"
    exit 1
fi

IMAGE_FILTER="${1}"

declare -a REGIONS=($(aws ec2 describe-regions --output json | jq '.Regions[].RegionName' | tr "\\n" " " | tr -d "\""))
for r in "${REGIONS[@]}" ; do
    ami=$(aws ec2 describe-images --query 'reverse(sort_by(Images, &Name))[:1].[ImageId]' --filters "Name=name,Values=${IMAGE_FILTER}" --region ${r} --output json | jq '.[0][0]')
    printf "${r}: Id: ${ami}\\n"
done