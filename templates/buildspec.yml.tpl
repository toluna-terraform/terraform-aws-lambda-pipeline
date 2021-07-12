version: 0.2
phases:
  install:
    runtime-versions:
      "${RUNTIME_TYPE}": "${RUNTIME_VERSION}" 
  pre_build:
    commands:
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - LAMBDA_NAME="${LAMBDA_NAME}"
      - RUNTIME="${RUNTIME_TYPE}-${RUNTIME_VERSION}"
  build:
    commands:
      - echo Build started on `date`
      - sam package --template-file "${TEMPLATE_FILE_PATH}" --output-template-file package.yml  --s3-bucket "${S3_BUCKET}"
  post_build:
    commands:
      - echo $APPSPEC > appspec.json
      - sed -i "s+<RUNTIME>+$RUNTIME+g" appspec.json

artifacts:
  files:
    - appspec.ymls  
    - package.yml
  discard-paths: yes
