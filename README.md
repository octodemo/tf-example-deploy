# Demo Bookstore v3

This is a simple Maven project that builds a standalone JAR which contains a Jetty webserver and a simple bookstore servlet. The application is able
to be built into a container and then available to be deployed as an Azure Web App.

![bookstore](https://user-images.githubusercontent.com/681306/114581130-5e2d4b00-9c77-11eb-837b-4efaefa29e39.png)



## Terraform Deployment

Terraform is provided to deploy the application to an Azure web app for this repository in the [terraform](./terraform) directory, it uses
Terragrunt to perform an injection of a Remote state backend for Azure to store our state for each deployment.

The terraform deployment will look up the existing resource group and app plan and then deploy the specified container in to a web app for access from the internet. The containers are expected to
come from the GHCR in this example and are public, so that we do not have to deal with credentials in the example for this.

It is strongly advised that you would use credentials and even a ACR to host these containers closer to the deployment so that you can control access in a consitent system as the deployment. GHCR is better suited for staging in this example.


### GitHub Actions Workflows

There are a few supporting workflows in this reposiotry but we are focusing only on the deployment with terraform aspects in this example.

#### [terraform_deployment.yml](./.github/workflows/terraform_deployment.yml)

This workflow uses a `workflow_dispatch` event as a trigger to provide a manual workflow trigger with useer inputs. It can also be triggered programmatically via the API, which is what is done from the [deployment_issue.yml](./.github/workflows/deployment_issue.yml) workflow.

The inputs for this workflow define the environment name and the container, as well as some extra metadata that is relevant for tracking and reporting (user/actor and an issue to report status to).

The workflow consists of three steps"

1. `invocation_details`: reporting of the inputs and initial optional reporting would occur here.

2. `deploy_details`: using the inputs and validating the parameters and using them to check for the existence of the container image specified, failing if not available

3. `deploy_to_cloud`: using the validated parameters, target an environment (gaining access to the secrets specific to that environment along with protection rules, like required reviewers) and then perform the deployment of the container as a web app, all using Terraform. Upon successful deployment also register that URL with the environment, so that everything is linked up in GitHub

4. `post_deploy`: optional post reporting steps to update infomration on the tracking issue reporting the success or failure


#### [deployment_issue.yml](./.github/workflows/deployment_issue.yml)

This workflow listens for issues being opened or reopeneded that meet the requirements of:
* issue has a `deployment` label
* issue is assigned to our automation user `octodemobot`

If these conditions are met, then we assume that the issue has come from our issue template (which was used to collect user information in a specific format to make parsing the data possible).
If this is the case using markletplace actions we extract the data and then report the extracted data as summary, and if successful, then invoke a deployment using the `terraform_deployment.yml` workflow above.

![Issue Workflow Results](https://user-images.githubusercontent.com/681306/197496245-69db4138-6755-44b7-9e05-0bb096abf556.png)

Note that for this to be possible, you cannot use the `${{ secrets.GITHUB_TOKEN }}` as that lacks the ability to chain Actions workflows. For this we are using a GitHub Application to obtain a temporary token. See https://github.com/peter-murray/workflow-application-token-action for more details.
