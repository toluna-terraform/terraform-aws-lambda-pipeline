version: 0.2
env:
  parameter-store:
    DEPLOYMENT_ID: "/infra/${app_name}-${env_name}/deployment_id"
    CONSUL_PROJECT_ID: "/infra/${app_name}-${env_type}/consul_project_id"
    CONSUL_HTTP_TOKEN: "/infra/${app_name}-${env_type}/consul_http_token"
    
phases:
  pre_build:
    commands:
        - yum install -y yum-utils
        - yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
        - yum -y install terraform consul
        - export CONSUL_HTTP_ADDR=https://consul-cluster-test.consul.$CONSUL_PROJECT_ID.aws.hashicorp.cloud
        - printf "%s\n%s\nus-east-1\njson" | aws configure --profile ${aws_profile}
  build:
    commands:
      - |
        echo "Shifting traffic"
        cd $CODEBUILD_SRC_DIR/terraform/shared
        terraform init
        terraform workspace select shared-${env_type}
        terraform init
        terraform apply -target=module.dns -auto-approve || exit 1
