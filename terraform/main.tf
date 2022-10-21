terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.28.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the resource group
data "azurerm_resource_group" "rg" {
  name     = var.azure_resource_group
}

data "azurerm_service_plan" "appserviceplan" {
  name                = var.azure_service_plan
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_linux_web_app" "webapp" {
  name                  = "webapp-${var.environment_name}-${random_integer.ri.result}"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  service_plan_id       = data.azurerm_service_plan.appserviceplan.id

  site_config {
    application_stack {
      docker_image = var.container_image
      docker_image_tag = var.container_tag
    }
  }
}

output "website_url" {
  value = azurerm_linux_web_app.webapp.default_hostname
}