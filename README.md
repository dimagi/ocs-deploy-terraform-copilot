# chatbots-deploy

* GitHub Actions push to ECR
* Pipline deploys to ECS

```shell

# 1Password "op://m735emfqlvrittifn4s6eioina/Cloudflare DNS API Key/credential"
export CLOUDFLARE_API_TOKEN=***
export AWS_PROFILE=ocs-test
aws sso login --profile ocs-test

cd terraform/envs/prod

# For a fresh install you must set up the network first:
terragrunt run-all --terragrunt-include-dir cert --terragrunt-include-dir network [plan,apply]

* Copy:
  * `vpc_id` to `copilot/environments/<env>/manifest.yml:networking.vpc.id`
  * `private_subnets` to `copilot/environments/<env>/manifest.yml:networking.vpc.subnets.private`
  * `public_subnets` to `copilot/environments/<env>/manifest.yml:networking.vpc.subnets.public`

terragrunt run-all --terragrunt-include-dir alb --terragrunt-include-dir rds --terragrunt-include-dir redis [plan,apply]

Copy:

* `alb_arn` to `copilot/chatbots/manifest.yml:http.alb`

terragrunt run-all --terragrunt-include-dir rds [plan,apply]

Copy:
* `db_instance_address_secret_arn` to `copilot/chatbots/manifest.yml:secrets.POSTGRES_HOST` 
* `db_instance_master_user_secret_arn` to `copilot/chatbots/manifest.yml:secrets.POSTGRES_USER` (append `:username::`)
* `db_instance_master_user_secret_arn` to `copilot/chatbots/manifest.yml:secrets.POSTGRES_PASSWORD` (append `:password::`)

terragrunt run-all --terragrunt-include-dir redis [plan,apply]

Copy:
* `redis_instance_url_secret_arn` to `copilot/chatbots/manifest.yml:secrets.REDIS_URL`

terragrunt run-all  --terragrunt-include-dir secrets [plan,apply]

* Copy `django_secret_key_id` to `copilot/chatbots/manifest.yml:secrets.SECRET_KEY`

copilot app init ocs-dimagi
copilot env init -n test --import-vpc-id vpc-xx --import-public-subnets subnet-xx,subnet-xx --import-private-subnets subnet-xx,subnet-xx
copilot svc init --name ocs-web --svc-type "Load Balanced Web Service" --dockerfile ./Dockerfile


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
