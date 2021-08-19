** In this folder you able to find a Buildspec.yml.tpl sample for SAM Deploy **

```
version: 0.2
phases:
  install:
    runtime-versions:
      "${RUNTIME_TYPE}": "${RUNTIME_VERSION}" 
  pre_build:
    commands:
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - RUNTIME="${RUNTIME_TYPE}-${RUNTIME_VERSION}"
  build:
    commands:
      - cp ${TEMPLATE_FILE_PATH}/samconfig.toml ${TEMPLATE_FILE_PATH}/.aws-sam/build/
      - cd ${TEMPLATE_FILE_PATH}/.aws-sam/build
      - sam deploy --template-file template.yaml --config-file samconfig.toml --no-confirm-changeset --no-fail-on-empty-changeset

```