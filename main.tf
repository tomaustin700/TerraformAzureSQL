terraform {
  backend "azurerm" {
    resource_group_name  = "Terraform"
    storage_account_name = "terraformta"
    container_name       = "tstate"
    key                  = "azuresql.terraform.tfstate"

  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

}


provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_client_config" "current" {}

variable "db_password" {}

resource "azurerm_resource_group" "rg" {
  name     = "database-rg"
  location = "uksouth"
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "taterraformsqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = var.db_password
  minimum_tls_version          = "1.2"

}

resource "azurerm_mssql_database" "db" {
  name           = "acctest-db-d"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false


}
