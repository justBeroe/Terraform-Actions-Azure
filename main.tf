terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
  }

 backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "taskboardstorageberoe"
    container_name       = "taskboardcontainerberoe"
    key                  = "terraform.tfstate"
  }

}

 


provider "azurerm" {
  # Configuration options
  subscription_id = "b3027ed2-38b2-4646-a5f1-f33639a21992"

  features {


  }
}


resource "random_integer" "ri" {
  min = 10000
  max = 99999

}

resource "azurerm_resource_group" "beroerg" {
  name = "${var.resource_group_name}-${random_integer.ri.result}"
  # location = "West Europe"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "beroeasp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.beroerg.name
  location            = azurerm_resource_group.beroerg.location
  os_type             = "Linux"
  sku_name            = "F1"
  # In an Azure App Service Plan, the SKU (Stock Keeping Unit) type defines the pricing tier and performance characteristics of the plan. The "F1" SKU refers to the Free Tier of Azure App Service.
}

resource "azurerm_linux_web_app" "beroelwa" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.beroerg.name
  location            = azurerm_service_plan.beroeasp.location
  service_plan_id     = azurerm_service_plan.beroeasp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false

  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserverberoe.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.beroedb.name};User ID=${azurerm_mssql_server.sqlserverberoe.administrator_login};Password=${azurerm_mssql_server.sqlserverberoe.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_app_service_source_control" "githubberoe" {
  app_id                 = azurerm_linux_web_app.beroelwa.id
  repo_url               = var.github_repo
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "sqlserverberoe" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.beroerg.name
  location                     = azurerm_resource_group.beroerg.location
  version                      = "12.0"
  administrator_login          = var.sql_user
  administrator_login_password = var.sql_user_pass
}

resource "azurerm_mssql_database" "beroedb" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sqlserverberoe.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
  # enclave_type = "VBS"

  # tags = {
  #   foo = "bar"
  # }

  # prevent the possibility of accidental data loss
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_mssql_firewall_rule" "beroefw" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserverberoe.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

