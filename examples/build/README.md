** In this folder you able to find a Buildspec.yml.tpl sample for SAM Build **

```
version: 0.2
phases:
  install:
    runtime-versions:
      "${RUNTIME_TYPE}": "${RUNTIME_VERSION}" 
    commands:
      - export PATH="$PATH:/root/.dotnet/tools"
      - export ADO_USER=${ADO_USER}
      - export ADO_PASSWORD=${ADO_PASSWORD}
      - export VSS_NUGET_EXTERNAL_FEED_ENDPOINTS="{\"endpointCredentials\":[{\"endpoint\":\"https://pkgs.dev.azure.com/Toluna/_packaging/Toluna/nuget/v3/index.json\", \"username\":\"$ADO_USER\", \"password\":\"$ADO_PASSWORD\"}] }"
  pre_build:
    commands:
      - dotnet nuget add source -n Toluna-ADO https://pkgs.dev.azure.com/Toluna/_packaging/Toluna/nuget/v3/index.json -u $ADO_USER -p $ADO_PASSWORD --store-password-in-clear-text
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - RUNTIME="${RUNTIME_TYPE}-${RUNTIME_VERSION}"
      - dotnet restore /p:Configuration=Release /p:Platform="Any CPU" ${SLN_PATH}
  build:
    commands:
      - echo Build started on `date`
      - cd ${TEMPLATE_FILE_PATH} && sam build

artifacts:
  files:
    - '**/*'
  discard-paths: no
```