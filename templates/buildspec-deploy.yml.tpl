version: 0.2
env:
  parameter-store:
    USER: "/app/bb_user"  
    PASS: "/app/bb_app_pass"
phases:
  install:
    runtime-versions:
      "${RUNTIME_TYPE}": "${RUNTIME_VERSION}" 
  pre_build:
    commands:
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - RUNTIME="${RUNTIME_TYPE}-${RUNTIME_VERSION}"
      - pip install jinja2-cli
      - export COMMIT_ID=$(cat commit_id.txt)
  build:
    commands:
      - |
        if [ "${PIPELINE_TYPE}" != "cd" ]; then
          aws s3 cp s3://s3-codepipeline-${APP_NAME}-${ENV_TYPE}/${FROM_ENV}/$COMMIT_ID.yaml template.yaml
        else
          aws s3 cp s3://s3-codepipeline-${APP_NAME}-${ENV_TYPE}/${FROM_ENV}/LATEST.yaml template.yaml
        fi
        if [ "${PIPELINE_TYPE}" != "cd" ]; then
          export COMMIT_ID=$(cat commit_id.txt)
        else 
          export COMMIT_ID="${FROM_ENV}"
        fi
        jinja2 $CODEBUILD_SRC_DIR/terraform/app/samconfig.toml.j2 -D env=${ENV_NAME} -D commit_id=$COMMIT_ID -D env_type=${ENV_TYPE} -o samconfig.toml
        sam deploy --template-file template.yaml --config-file samconfig.toml
  post_build:
    commands:
      - |
        STATE="SUCCESSFUL"
        DESCRIPTION="Build ended successfully"
        if [ "$CODEBUILD_BUILD_SUCCEEDING" == "0" ]; then
            STATE="FAILED"
            DESCRIPTION="Build failed"
        fi
      - |
        REPORT_URL="https://console.aws.amazon.com/codesuite/codepipeline/pipelines/codepipeline-${APP_NAME}-${ENV_NAME}"
        URL="https://api.bitbucket.org/2.0/repositories/tolunaengineering/${APP_NAME}/commit/$COMMIT_ID/statuses/build/"
        curl --request POST --url $URL -u "$USER:$PASS" --header "Accept:application/json" --header "Content-Type:application/json" --data "{\"key\":\"${APP_NAME} Deploy\",\"state\":\"SUCCESSFUL\",\"description\":\"Deployment to ${ENV_NAME} succeeded\",\"url\":\"$REPORT_URL\"}"    
        bash -c "if [ /"$CODEBUILD_BUILD_SUCCEEDING/" == /"0/" ]; then exit 1; fi"
        if [ "${PIPELINE_TYPE}" != "dev" ]; then
          echo "Deployed to ${ENV_NAME}"
          aws s3 cp template.yaml s3://s3-codepipeline-${APP_NAME}-${ENV_TYPE}/${ENV_NAME}/LATEST.yaml          
        fi


                