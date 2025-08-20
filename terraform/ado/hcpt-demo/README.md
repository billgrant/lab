## Best Practices

### Deployment Pipeline

1. **Review Plans**: Always review the published plan results before allowing the apply step to run
2. **Branch Protection**: Consider using branch policies to require plan review before merging
3. **Environment Separation**: Use different variable groups and HCP Terraform workspaces for different environments
4. **State Management**: Let HCP Terraform handle state management rather than storing state in Azure DevOps

### Destroy Pipeline

1. **Manual Triggers Only**: Never enable automatic triggers for destroy pipelines
2. **Access Restrictions**: Limit destroy pipeline access to senior team members only
3. **Environment Verification**: Always double-check you're targeting the correct environment
4. **Data Backup**: Ensure critical data is backed up before destruction
5. **Team Communication**: Notify stakeholders before destroying shared infrastructure

### General Best Practices

1. **Separate Pipelines**: Keep deployment and destroy as separate pipelines for safety
2. **Environment Isolation**: Use separate HCP Terraform workspaces for dev/staging/production
3. **Version Control**: Pin Terraform versions for production workloads instead of using 'latest'
4. **Monitoring**: Set up alerts for pipeline failures and successful destructions# Azure DevOps Terraform Pipeline

This Azure DevOps pipeline automates Terraform infrastructure deployment using HashiCorp Cloud Platform (HCP) Terraform for state management and execution.

## Overview

The pipeline performs a complete Terraform workflow: initialization, planning, and applying infrastructure changes. It integrates with HCP Terraform (formerly Terraform Cloud) for remote state management and collaborative workflows.

## Prerequisites

### Variable Groups

The pipeline requires the following variable group to be configured in Azure DevOps:

- **terraform-env**: Contains environment-specific variables including:
  - `terraform-api-token`: API token for authenticating with HCP Terraform

### Required Extensions

- **Terraform Extension for Azure DevOps** - Provides TerraformInstaller and TerraformCLI tasks

## Pipeline Steps

### 1. Terraform Installation

```yaml
- task: TerraformInstaller@2
  inputs:
    terraformVersion: "latest"
```

**Purpose**: Downloads and installs the latest version of Terraform CLI on the build agent.

**Configuration**:

- Uses the latest available Terraform version
- Automatically handles installation across different agent operating systems

### 2. HCP Terraform Authentication Setup

```yaml
- script: |
    RC_FILE=".terraformrc"
    cat > ${RC_FILE} << EOF
    credentials "app.terraform.io" {
      token = "$(terraform-api-token)"
    }
    EOF
    mv .terraformrc ~/.terraformrc
    export TF_CLI_CONFIG_FILE="~/.terraformrc"
  name: terraform_cloud_credentials
  displayName: "HCP Terraform Credentials"
```

**Purpose**: Configures Terraform CLI to authenticate with HCP Terraform using API token.

**What it does**:

- Creates a `.terraformrc` configuration file with HCP Terraform credentials
- Moves the configuration to the user's home directory
- Sets the `TF_CLI_CONFIG_FILE` environment variable to point to the configuration

**Security Note**: The API token is securely retrieved from the Azure DevOps variable group.

### 3. Terraform Initialization

```yaml
- task: TerraformCLI@2
  inputs:
    command: "init"
    allowTelemetryCollection: true
```

**Purpose**: Initializes the Terraform working directory and downloads required providers.

**Configuration**:

- Runs `terraform init` command
- Enables telemetry collection for HashiCorp usage analytics
- Downloads provider plugins and modules
- Configures remote backend (HCP Terraform)

### 4. Terraform Plan

```yaml
- task: TerraformCLI@2
  inputs:
    command: "plan"
    allowTelemetryCollection: true
    publishPlanResults: "hcpt_demo"
```

**Purpose**: Creates an execution plan showing what actions Terraform will take.

**Configuration**:

- Runs `terraform plan` command
- Publishes plan results to Azure DevOps with artifact name 'hcpt_demo'
- Enables telemetry collection
- Plan output is available for review in the Azure DevOps interface

### 5. Terraform Apply

```yaml
- task: TerraformCLI@2
  inputs:
    command: "apply"
    allowTelemetryCollection: true
```

**Purpose**: Applies the Terraform configuration to create or update infrastructure.

**Configuration**:

- Runs `terraform apply` command with auto-approval
- Executes the changes planned in the previous step
- Enables telemetry collection

### 6. Credentials Cleanup

```yaml
- script: |
    rm ~/.terraformrc
  name: terraform_cloud_credentials_cleanup
  displayName: "HCP Terraform Credentials Clean Up"
```

**Purpose**: Removes the Terraform credentials file for security cleanup.

**Security Practice**: Ensures sensitive credential files don't persist on the build agent after pipeline completion.

## Terraform Configuration Setup

### Required Terraform Backend Configuration

Add the following configuration block to your main Terraform file (e.g., `main.tf` or `versions.tf`) to configure HCP Terraform as the remote backend:

```hcl
terraform {
  cloud {
    organization = "<YOUR_ORG_NAME>"

    workspaces {
      name = "<YOUR_WORKSPACE_NAME>"
    }
  }
}
```

**Configuration Steps**:

1. Replace `<YOUR_ORG_NAME>` with your actual HCP Terraform organization name
2. Replace `<YOUR_WORKSPACE_NAME>` with your workspace name in HCP Terraform
3. Ensure this block is present before running the pipeline

**Important Notes**:

- This configuration tells Terraform to use HCP Terraform for remote state storage and execution
- The workspace name must match exactly with what's configured in your HCP Terraform account
- This replaces any local backend configuration

## Configuration Requirements

### HCP Terraform Setup

1. **Organization**: Ensure you have an HCP Terraform organization set up
2. **Workspace**: Configure a workspace that matches your Terraform configuration
3. **API Token**: Generate an API token with appropriate permissions for your workspace

### Azure DevOps Setup

1. **Variable Group**: Create `terraform-env` variable group with required secrets
2. **Service Connection**: May require additional service connections depending on your cloud provider
3. **Repository**: Ensure your Terraform configuration files are in the repository

## Security Considerations

- **API Token Storage**: The HCP Terraform API token is stored securely in Azure DevOps variable groups
- **Credential Cleanup**: Credentials are automatically removed after pipeline execution
- **Remote State**: State files are stored securely in HCP Terraform, not in the repository

## Monitoring and Troubleshooting

### Plan Results

- Review published plan results in Azure DevOps before apply step
- Plan artifacts are stored with name 'hcpt_demo' for historical reference

### Common Issues

1. **Authentication Failures**: Verify the `terraform-api-token` variable is correctly set
2. **Initialization Errors**: Check that HCP Terraform workspace is properly configured
3. **Apply Failures**: Review Terraform logs in Azure DevOps pipeline output

### Telemetry

The pipeline enables Terraform telemetry collection to help HashiCorp improve their products. This can be disabled by setting `allowTelemetryCollection: false` if required by your organization's policies.

## Destroy Pipeline

For infrastructure teardown, use this separate destroy pipeline. This pipeline is triggered manually to prevent accidental destruction of resources.

### Pipeline Configuration

```yaml
trigger: none

variables:
  - group: terraform-env

steps:
  - task: TerraformInstaller@2
    inputs:
      terraformVersion: "latest"

  - script: |
      RC_FILE=".terraformrc"
      cat > ${RC_FILE} << EOF
      credentials "app.terraform.io" {
        token = "$(terraform-api-token)"
      }
      EOF
      mv .terraformrc ~/.terraformrc
      export TF_CLI_CONFIG_FILE="~/.terraformrc"
    name: terraform_cloud_credentials
    displayName: "HCP Terraform Credentials"

  - task: TerraformCLI@2
    inputs:
      command: "init"
      allowTelemetryCollection: true

  - task: TerraformCLI@2
    inputs:
      command: "destroy"
      allowTelemetryCollection: true

  - script: |
      rm ~/.terraformrc
    name: terraform_cloud_credentials_cleanup
    displayName: "HCP Terraform Credentials Clean Up"
```

### Destroy Pipeline Steps

#### 1. Manual Trigger Only

```yaml
trigger: none
```

**Purpose**: Prevents accidental infrastructure destruction by requiring manual pipeline execution.

**Security Feature**: This ensures infrastructure is only destroyed when explicitly intended by an authorized user.

#### 2. Terraform Installation

Same as the deployment pipeline - installs the latest Terraform version.

#### 3. HCP Terraform Authentication Setup

Identical to deployment pipeline - configures API authentication with HCP Terraform.

#### 4. Terraform Initialization

Same initialization process to prepare the working directory and download providers.

#### 5. Terraform Destroy

```yaml
- task: TerraformCLI@2
  inputs:
    command: "destroy"
    allowTelemetryCollection: true
```

**Purpose**: Destroys all infrastructure resources defined in the Terraform configuration.

**Configuration**:

- Runs `terraform destroy` command with auto-approval
- Removes all resources that were created by the Terraform configuration
- Enables telemetry collection

#### 6. Credentials Cleanup

Same cleanup process to remove sensitive credential files from the build agent.

### Destroy Pipeline Safety Considerations

**Manual Execution Required**: The `trigger: none` configuration ensures this pipeline cannot be accidentally triggered by code commits or scheduled runs.

**Review Before Execution**:

- Always review what resources will be destroyed before running this pipeline
- Consider running `terraform plan -destroy` locally first to see the destruction plan
- Ensure you have backups of any critical data that might be lost

**Access Control**:

- Restrict access to this pipeline to authorized personnel only
- Consider requiring additional approvals for production environment destruction
- Use Azure DevOps environments and approval gates for additional safety

**Best Practices for Destruction**:

1. **Backup Data**: Ensure all important data is backed up before destruction
2. **Verify Environment**: Confirm you're destroying the correct environment/workspace
3. **Team Communication**: Notify team members before destroying shared resources
4. **Documentation**: Document the reason for infrastructure destruction
