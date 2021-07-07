version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --no-include-email --region $AWS_REGION)
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - S3_BUCKET="${S3_BUCKET}"
      - IMAGE_REPO_NAME="${IMAGE_REPO_NAME}"
  build:
    commands:
      - echo Build started on `date`
      - cd ${DOCKERFILE_PATH}
      - sam package --template-file template.yml --output-template-file package.yml  --s3-bucket $S3_BUCKET
  post_build:
    commands:
      - echo $APPSPEC > appspec.json

artifacts:
  files:
    - appspec.yml
    - package.yml
  discard-paths: yes
