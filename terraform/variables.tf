variable "azure_resource_group" {
  type        = string
  description = "Azure resource group name"
}

variable "azure_service_plan" {
  type        = string
  description = "Azure service plan"
}

variable "environment_name" {
  type        = string
  description = "Environment"
}

variable "container_image" {
  type        = string
  description = "Container image, fully qualified"
}

variable "container_tag" {
  type        = string
  description = "Container tag"
}