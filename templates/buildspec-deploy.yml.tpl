version: 0.2
phases:
  install:
    runtime-versions:
      "${RUNTIME_TYPE}": "${RUNTIME_VERSION}" 
  pre_build:
    commands:
      - CODEBUILD_RESOLVED_SOURCE_VERSION="$CODEBUILD_RESOLVED_SOURCE_VERSION"
      - RUNTIME="${RUNTIME_TYPE}-${RUNTIME_VERSION}"
      - pip install jinja2-cli
  build:
    on-failure: ABORT
    commands:
      - |
        if [ "${PIPELINE_TYPE}" = "dev" ]; then
          app_id=$(aws serverlessrepo list-applications --query 'Applications[?Name==`${APP_NAME}-${ENV_NAME}`].ApplicationId' --output text)
          LATEST_VERSION=$(aws serverlessrepo list-application-versions --application-id $app_id --query 'Versions[].SemanticVersion' | jq last)
          LATEST_VERSION="$${LATEST_VERSION%\"}"
          export LATEST_VERSION="$${LATEST_VERSION#\"}"
        elif [ "${PIPELINE_TYPE}" = "ci" ]; then
          app_id=$(aws serverlessrepo list-applications --query 'Applications[?Name==`${APP_NAME}`].ApplicationId' --output text)
          LATEST_VERSION=$(aws serverlessrepo list-application-versions --application-id $app_id --query 'Versions[].SemanticVersion' | jq last)
          LATEST_VERSION="$${LATEST_VERSION%\"}"
          export LATEST_VERSION="$${LATEST_VERSION#\"}"
        else
          IFS=':'
          declare -a labels=($(aws serverlessrepo list-applications --query 'Applications[?Name==`${APP_NAME}`].Labels[]' --output text))
          for i in "$${labels[@]}"
          do
            read -a strarr <<< "$i"
            if [ "$${strarr[0]}" = "${FROM_ENV}" ]; then
              LATEST_VERSION="$${strarr[1]//_/.}" 
              LATEST_VERSION="$${LATEST_VERSION%\"}"
              export LATEST_VERSION="$${LATEST_VERSION#\"}"
            fi
          done
          IFS=
        fi
        template_url=$(aws serverlessrepo create-cloud-formation-template --application-id $app_id --semantic-version $LATEST_VERSION --query 'TemplateUrl' --output text)
        wget -O template.yaml $template_url
        #check conditions and sed -i '/PreTraffic/d' template.yaml ? hooks for both
        jinja2 $CODEBUILD_SRC_DIR/terraform/app/samconfig.toml.j2 -D PIPELINE_TYPE=${PIPELINE_TYPE} -D RUN_TESTS=${RUN_TESTS} -D env=${ENV_NAME} -D env_type=${ENV_TYPE} -o samconfig.toml
        sam deploy --template-file template.yaml --config-file samconfig.toml
  post_build:
    on-failure: ABORT
    commands:
      - |
        if [ "${PIPELINE_TYPE}" != "dev" ]; then
          NEW_VERSION=$${LATEST_VERSION//./_}
          NEW_LABEL="${ENV_NAME}:$NEW_VERSION"
          declare -a labels=($(aws serverlessrepo list-applications --query 'Applications[?Name==`${APP_NAME}`].Labels[]' --output text))
          if [[ " $${labels[@]} " == *"${FROM_ENV}"* ]]; then
            IFS=':'
            for i in "$${labels[@]}"
            do
              read -a strarr <<< "$i"
              if [ "$${strarr[0]}" = "${FROM_ENV}" ]; then
                IFS=
                $${labels[i]}="${ENV_NAME}:$NEW_VERSION"
              fi
            done
          else
            IFS=
            labels[$${#labels[@]}]="${ENV_NAME}:$NEW_VERSION"
          fi
          app_id=$(aws serverlessrepo list-applications --query 'Applications[?Name==`responses`].ApplicationId' --output text)
          aws serverlessrepo update-application --application-id $app_id --labels $${labels[@]} --no-cli-pager
        fi
                