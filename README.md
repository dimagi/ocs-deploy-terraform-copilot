# chatbots-deploy

```shell

# 1Password "op://m735emfqlvrittifn4s6eioina/Cloudflare DNS API Key/credential"
export CLOUDFLARE_API_TOKEN=***
export AWS_PROFILE=ocs-test
aws sso login --profile ocs-test

cd terraform/envs/prod
terragrunt run-all []--terragrunt-include-dir network --terragrunt-include-dir rds ...]
copilot app init ocs-dimagi
copilot env init -n test --import-vpc-id vpc-xx --import-public-subnets subnet-xx,subnet-xx --import-private-subnets subnet-xx,subnet-xx
copilot svc init --name ocs-web --svc-type "Load Balanced Web Service" --dockerfile ./Dockerfile

# update settings e.g. RDS, Redis etc
* db_instance_master_user_secret_arn
* db_instance_address_secret_arn
* django_secret_key_id

copilot svc deploy --name ocs-web --env test

copilot svc exec --name ocs-web --env test -c /bin/bash

copilot svc logs --name ocs-web --env test
```


Deletion:
 * protected
   * alb
   * rds
 * S3
   * delete contents 
