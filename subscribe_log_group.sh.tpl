##### DO NOT CHANGE INDENTATION !!! #####
        export CORALOGIX_ARN=$(aws lambda get-function --function-name coralogix-cloudwatch-forwarder-quota-service --query 'Configuration.FunctionArn' --output text)
                if [ $CORALOGIX_ARN != "null" ]; then
                    export LOG_GROUP_NAME=$(aws lambda list-functions --query 'Functions[?starts_with(FunctionName,`quota-service-devops`)].FunctionName' --output text)
                    export LOG_GROUP_ARN=$(aws logs describe-log-groups --log-group-name-prefix /aws/lambda/$LOG_GROUP_NAME --query 'logGroups[0].arn' --output text)
                    if [ $LOG_GROUP_ARN = "None" ]; then aws logs create-log-group --log-group-name /aws/lambda/$LOG_GROUP_NAME; fi  
                    LOG_GROUP_ARN=$(aws logs describe-log-groups --log-group-name-prefix /aws/lambda/$LOG_GROUP_NAME --query 'logGroups[0].arn' --output text)
                    aws lambda add-permission --function-name coralogix-cloudwatch-forwarder-quota-service --statement-id coralogix-${ENV_NAME}-${uuid()} --action lambda:InvokeFunction --principal logs.us-east-1.amazonaws.com --source-arn $LOG_GROUP_ARN --output text
                    aws logs put-subscription-filter --filter-name ${ENV_NAME} --destination-arn $CORALOGIX_ARN --log-group-name "/aws/lambda/$LOG_GROUP_NAME" --filter-pattern ""
                    export COROLOGIX_APIKEY=$(aws ssm get-parameter --name /infra/coralogix-tags/apikey --with-decryption --query 'Parameter.Value' --output text) 
                    curl -X POST "https://webapi.coralogix.com/api/v1/external/tags" \
                    -H "Content-Type: application/json" \
                    -H "Authorization: Bearer $COROLOGIX_APIKEY" \
                    -H "maskValue: false" \
                    -d "{\"timestamp\":\""$(date +%s%N | cut -b1-13)"\",\"name\":\"/aws/lambda/$LOG_GROUP_NAME\",\"application\":[\"${ENV_NAME}\"],\"subsystem\":[\"${APP_NAME}\"]}"
                fi
                
    