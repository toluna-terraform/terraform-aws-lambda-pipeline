version: 0.2
env:
  parameter-store:
    USER: "/app/ado_user"
    PASS: "/app/ado_password"
    BB_USER: "/app/bb_user"
    BB_PASS: "/app/bb_pass"
phases:
  install:
    runtime-versions:
      "${RUNTIME_TYPE}": "${RUNTIME_VERSION}" 
    commands:
      - export PATH="$PATH:/root/.dotnet/tools"
  pre_build:
    commands:
      - |
        if [ "${PIPELINE_TYPE}" != "dev" ]; then
          BUILD_CONDITION=$(cat ci.txt)
          PR_NUMBER=$(cat pr.txt)
          SRC_CHANGED=$(cat src_changed.txt)
          HEAD=$(cat head.txt)
        else
          echo "true" > ci.text
          BUILD_CONDITION=$(cat ci.txt)
          PR_NUMBER=$(cat pr.txt)
          echo "true" > src_changed.txt
          SRC_CHANGED=$(cat src_changed.txt)
          HEAD=$(cat head.txt)
        fi
      - dotnet nuget add source https://pkgs.dev.azure.com/Toluna/_packaging/Toluna/nuget/v3/index.json --name Toluna-ADO --username $USER --password $PASS --store-password-in-clear-text
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - RUNTIME="${RUNTIME_TYPE}-${RUNTIME_VERSION}"
      - dotnet restore /p:Configuration=Release /p:Platform="Any CPU" ${SLN_PATH}
      - pip install jinja2-cli
      - export COMMIT_ID=$(cat commit_id.txt)
      - export REPORT_URL="https://console.aws.amazon.com/codesuite/codebuild/projects?"
      - |
        URL="https://api.bitbucket.org/2.0/repositories/tolunaengineering/${APP_NAME}/commit/$COMMIT_ID/statuses/build/"
        curl --request POST --url $URL -u "$BB_USER:$BB_PASS" --header "Accept:application/json" --header "Content-Type:application/json" --data "{\"key\":\"${APP_NAME} Build\",\"state\":\"INPROGRESS\",\"description\":\"${APP_NAME} Build is running\",\"url\":\"$REPORT_URL\"}"    
  build:
    commands:
      - |
        if [ "$BUILD_CONDITION" = "true" ] && [ "$SRC_CHANGED" = "true" ]; then
          echo Build started on `date`
          mkdir -p $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/.aws-sam/build/ && cp $CODEBUILD_SRC_DIR/terraform/app/samconfig.toml.j2 $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/.aws-sam/build/
          cd $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/.aws-sam/build
          jinja2 samconfig.toml.j2 -D env=${ENV_NAME} -D commit_id=$COMMIT_ID -D next_color=white -D env_type=${ENV_TYPE} -o $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/samconfig.toml
          VERSION_DATE=$(date '+%Y-%m-%d')
          if [ "${PIPELINE_TYPE}" != "dev" ]; then
            REPO_NAME="${APP_NAME}"
          else
            REPO_NAME="${APP_NAME}-${ENV_NAME}"
          fi
          #lookup version
          echo $CODEBUILD_WEBHOOK_ACTOR_ACCOUNT_ID
          jinja2 $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/template.yaml.j2 -D AUTHOR="Test Author" -D REPO_NAME=$REPO_NAME -D COMMIT_ID=$COMMIT_ID-$VERSION_DATE -D APP_NAME=${APP_NAME} -D ENV_NAME=${ENV_NAME} -D ENV_TYPE=${ENV_TYPE} -D PIPELINE_TYPE=${PIPELINE_TYPE} -o $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/template.yaml
          cd $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH} && sam build
          sam package -t $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/template.yaml  --s3-bucket s3-codepipeline-${APP_NAME}-${ENV_TYPE} --s3-prefix ${ENV_NAME} --force-upload --config-file $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/samconfig.toml --output-template-file $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/${ENV_NAME}_template.yaml
          aws s3 cp $CODEBUILD_SRC_DIR/${TEMPLATE_FILE_PATH}/${ENV_NAME}_template.yaml s3://s3-codepipeline-${APP_NAME}-${ENV_TYPE}/${ENV_NAME}/$COMMIT_ID.yaml
        fi  
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
      curl --request POST --url $URL -u "$BB_USER:$BB_PASS" --header "Accept:application/json" --header "Content-Type:application/json" --data "{\"key\":\"${APP_NAME} Build\",\"state\":\"$STATE\",\"description\":\"${APP_NAME} $DESCRIPTION\",\"url\":\"$REPORT_URL\"}"  

artifacts:
  files:
    - '**/*'
  discard-paths: no

