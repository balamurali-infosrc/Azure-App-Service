terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
       version = ">=3.0.0"
    }
  }
  required_version = ">= 1.0.0"
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
  default = "eastus2" # change to your region
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}
variable "function_name" {
  type    = string
  default = "demo-func-app"
}
# resource "random_string" "suffix" {
#   length  = 4
#   lower   = true
#   upper   = false
#   numeric = true
#   special = false
# }
# resource "azurerm_storage_account" "sa" {
#   name = substr(lower(replace("${var.function_name}sa", "-", "")), 0, 24)
# #  name                     = lower(replace("${var.function_name}sa", "-", ""))[0:24] # storage account name rules
#   # name                     = local.sa_name
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   # allow_blob_public_access = false   # allow_blob_public_access removed for compatibility
#   min_tls_version          = "TLS1_2"
#   blob_properties {
#     # disable public access
#     default_service_version = "2021-06-08"
#   }
# }


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
     depends_on = [azurerm_resource_group.rg]
#     depends_on = [azurerm_app_service_plan.func]  
}


resource "azurerm_app_service" "app" {
  name                = "${var.prefix}-webappInfo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "NODE|18-lts" # or "PYTHON|3.11" or container image "DOCKER|myimage:tag"
  }

  app_settings = {
     FUNCTIONS_WORKER_RUNTIME   = "node"   # change to "python" or "dotnet" as needed
    WEBSITE_RUN_FROM_PACKAGE   = "1"
    FUNCTIONS_EXTENSION_VERSION  = "~4"
    # AzureWebJobsStorage        = azurerm_storage_account.sa.primary_connection_string
  }
}


