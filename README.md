# Security Lab

## Trivy Scanner

Trivy is a simple and comprehensive vulnerability scanner for containers and other artifacts. A software vulnerability is a glitch, flaw, or weakness present in the software or in an Operating System. Trivy detects vulnerabilities of OS packages (Alpine, RHEL, CentOS, etc.) and application dependencies (Bundler, Composer, npm, yarn, etc.). Trivy is easy to use. Just install the binary and you're ready to scan. All you need to do for scanning is to specify a target such as an image name of the container.

### Instructions

1. Install Trivy on your machine. See https://aquasecurity.github.io/trivy/v0.53/getting-started/installation/
2. Go to the `terraform-insecure` directory.
3. Run the Trivy scanner for Terraform:
    ```bash
    trivy config .
    ```
4. Fix the vulnerabilities found by Trivy.
5. Run the Trivy scanner again to ensure that there are no vulnerabilities left.
6. Revert the changes made in the previous step (to have vulnerabilities again 😅).

## Checkov Scanner

Checkov is a static code analysis tool for infrastructure-as-code. It scans cloud infrastructure managed in Terraform, CloudFormation, Kubernetes, and more. Checkov scans cloud infrastructure for misconfigurations, compliance issues, and security vulnerabilities. It provides a simple way to validate that your infrastructure is secure and compliant.

### Instructions

1. Install Checkov on your machine. See https://www.checkov.io/2.Basics/Installing%20Checkov.html
2. Go to the `terraform-insecure` directory.
3. Run the Checkov scanner for Terraform:
    ```bash
    checkov -d .
    ```
4. Fix the issues found by Checkov.
5. Run the Checkov scanner again to ensure that there are no issues left.
6. You can now leave the directory as it is.

## TFLint Scanner

TFLint is a Terraform linter focused on possible errors, best practices, etc. It is a static analysis tool that checks Terraform configurations against predefined rules. TFLint is designed to be fast and helpful for developers in the Terraform ecosystem. It is a great tool to ensure that your Terraform code is following best practices and is free of errors.

### Instructions

1. Install TFLint on your machine. See https://github.com/terraform-linters/tflint?tab=readme-ov-file#installation
2. Go to the `terraform-lint-issues` directory.
3. Run the TFLint scanner for Terraform:
    ```bash
    tflint
    ```
4. Fix the issues found by TFLint.
5. Run the TFLint scanner again to ensure that there are no issues left.

# Secrets Management Lab

## Azure Secret Management

Azure Key Vault is a cloud service for securely storing and accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, etc. Azure Key Vault helps you to manage secrets, keys, and certificates. When you use Azure Key Vault, you can encrypt keys and secrets (such as authentication keys, storage account keys, data encryption keys, .PFX files, and passwords) using keys stored in Azure Key Vault.

We will create a Key Vault in Azure and store a secret in it. On the Terraform side, we will use the Azure Key Vault to create a Machine access policy for the secret.

The Machine access policy is a policy that allows a virtual machine to access the secret stored in the key vault without the need for a user to authenticate. This is useful when you want to automate the deployment of resources and need to access secrets securely.

### Instructions

1. Go to the `vault` directory.
2. Use the resource group created in the previous lab. By setting the variables in the `terraform.tfvars` file.
3. Create the vault with the following command:
    ```bash
    terraform init
    terraform apply
    ```
4. Copy the `vault_id` from the output.
5. Create a secret in the key vault with the cli command:
    ```bash
    az keyvault secret set --vault-name <key_vault_name> --name <secret_name> --value <secret_value>
    ```
6. Go to the `vm-vault` directory.
7. Use the resource group created in the previous lab. By setting the variables in the `terraform.tfvars` file. (with other variables for network and key vault)
8. Create the virtual machine with the following command:
    ```bash
    terraform init
    terraform apply
    ```
9. SSH into the virtual machine and check if the secret is accessible by running the following command:
    ```bash
    az keyvault secret show --vault-name <key_vault_name> --name <secret_name> --query value -o tsv
    ```
10. You can now clean up the resources by running:
    ```bash
    terraform destroy
    ```
11. You can now leave the directory as it is.


