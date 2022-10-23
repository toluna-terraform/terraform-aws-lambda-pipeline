version: 0.2

env:
  parameter-store:
    USER: "/app/bb_user"  
    PASS: "/app/bb_app_pass"
    RELEASE_HOOK_URL: "/app/jira_release_hook"

phases:
  pre_build:
    commands:
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - COMMENT="Pipeline has been done successfully."
      - PR_NUMBER=$(cat pr.txt)
      - SRC_CHANGED=$(cat src_changed.txt)
      - COMMIT_ID=$(cat commit_id.txt)
      - TEMPLATE_DIR="$CODEBUILD_SRC_DIR/"
  build:
    commands:
      - |
        if [ "${PIPELINE_TYPE}" == "ci" ]; then 
            cd  $TEMPLATE_DIR
            zip -r DEPLOYED_VERSION.zip -i sam-${ENV}-templated.yaml .
            aws s3 cp DEPLOYED_VERSION.zip s3://${S3_BUCKET}/${ENV}/
        fi
  post_build:
    commands:
      - |
        REPORT_URL="https://us-east-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/codepipeline-${APP_NAME}-${ENV}/view?region=us-east-1"
        URL="https://api.bitbucket.org/2.0/repositories/tolunaengineering/${APP_NAME}/commit/$COMMIT_ID/statuses/build/"
        curl --request POST --url $URL -u "$USER:$PASS" --header "Accept:application/json" --header "Content-Type:application/json" --data "{\"key\":\"${APP_NAME} Deploy\",\"state\":\"SUCCESSFUL\",\"description\":\"Deployment to qac succeeded\",\"url\":\"$REPORT_URL\"}"    
      - |
        if [ "${ENV}" == "prod" ] && [ "${ENABLE_JIRA_AUTOMATION}" == "true" ] ; then 
            export RELEASE_VERSION=$(cat new_version.txt)
            curl --request POST --url $RELEASE_HOOK_URL --header "Content-Type:application/json" --data "{\"data\": {\"releaseVersion\":\"$RELEASE_VERSION\"}}" || echo "No Jira to change"
        fi
      