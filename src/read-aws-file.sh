#!/usr/bin/env bash
set -e -o pipefail

getS3BucketName() {
    credentialsFile=$1
    path=${credentialsFile#"s3://"}
    IFS='/' read -ra NAMES <<< $path
    echo ${NAMES[0]}
}

getS3Path() {
    credentialsFile=$1
    path=${credentialsFile#"s3://"}
    var=''
    IFS='/' read -ra NAMES <<< $path
    for ELEMENT in ${NAMES[@]:1}; do
        var+="/$ELEMENT"
    done
    echo $var
}

credentialsFile=$1
awsIamRole=$2

credentials=$(curl --fail --silent --show-error http://169.254.169.254/latest/meta-data/iam/security-credentials/$awsIamRole)
awsAccessKeyId=$(echo $credentials | jq -r '.AccessKeyId')
awsSecretAccesskey=$(echo $credentials | jq -r '.SecretAccessKey')
awsToken=$(echo $credentials | jq -r '.Token')
currentDate=$(date +'%a, %d %b %Y %H:%M:%S %z')
s3BucketName=$(getS3BucketName $credentialsFile)
s3Path=$(getS3Path $credentialsFile)
strinToSign="GET\n\n\n${currentDate}\nx-amz-security-token:$awsToken\n/${s3BucketName}${s3Path}"
signature=$(echo -en "${strinToSign}" | openssl sha1 -hmac "$awsSecretAccesskey" -binary | base64)
curl --fail --silent --show-error --header "x-amz-security-token: $awsToken" --header "Host: ${s3BucketName}.s3.amazonaws.com" --header "Date: $currentDate" --header "Authorization: AWS $awsAccessKeyId:${signature}" "https://${s3BucketName}.s3.amazonaws.com${s3Path}"
