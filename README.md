# poc-gke-envs

The repository contains the environment definition

ansible-playbook -i inventory.yml --limit dev preparing.yml

Init Terraform backend

bash
cd ../structure/terraform/
terraform init -upgrade -backend-config=config.gcs.tfbackend 


Run Terraform plan

bash
terraform plan -input=false -out plan.out -var-file="terraform.tfvars.json"


## Apply configuration

bash
terraform apply -auto-approve -input=false plan.out


## Destroy environment

bash
terraform destroy -auto-approve -input=false -var-file="terraform.tfvars.json"