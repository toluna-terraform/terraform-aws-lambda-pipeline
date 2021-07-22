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
      - echo Build started on `date`
      - sam deploy --template-file package.yml --config-file samconfig.toml --no-confirm-changeset --no-fail-on-empty-changeset

