terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # pin to a 4.x+ release (adjust if you have a policy)
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
   subscription_id = "02a44fee-b200-4cf9-b042-9bd4aa3bebe6"
tenant_id = "63b9a1c1-375c-42cf-9c63-dc3798c7ae5e"
  # use_oidc =true
}

variable "prefix" {
  type    = string
  default = "demoapp"
}

variable "location" {
  type    = string
  default = "East US" # change to your region
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = "APP-plan1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind = "Linux"
  reserved = true

  sku {
    tier     = "Basic"
    size     = "F1"
    capacity = 1
  }
#     depends_on = [azurerm_app_service_plan.func]  
}


resource "azurerm_app_service" "app" {
  name                = "${var.prefix}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "NODE|18-lts" # or "PYTHON|3.11" or container image "DOCKER|myimage:tag"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}


