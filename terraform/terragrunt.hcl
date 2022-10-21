remote_state {
    backend         = "${get_env("TF_VAR_state_backend", "azurerm")}"

    generate = {
        path        = "backend.generated.tf"
        if_exists   = "overwrite_terragrunt"
    }

    # Generate the backend parameters as per the cloud provider, defaulting to azurerm
    config = jsondecode(
        templatefile("backend/${get_env("TF_VAR_state_backend", "azurerm")}.json",
            {
                github_repository_owner: "${local.config_vars.github_context.target_repository.owner}",
                github_repository_name: "${local.config_vars.github_context.target_repository.repo}",

                azure_storage_account_resource_group = "${get_env("TF_VAR_azure_storage_account_resource_group", "terraform_state")}",
                azure_storage_account_name = "${get_env("TF_VAR_storage_account_name", "githuboctodemoterraform")}",
            }
        )
    )
}