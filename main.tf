// -----------------------------------------------------------------------------
// Tags
// -----------------------------------------------------------------------------
locals {
  tags = {
    class      = var.tag_class
    instructor = var.tag_instructor
    semester   = var.tag_semester
  }
}

// -----------------------------------------------------------------------------
// Random Suffix Generator
// -----------------------------------------------------------------------------
resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// -----------------------------------------------------------------------------
// Resource Group
// -----------------------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location = var.location

  tags = local.tags
}

// -----------------------------------------------------------------------------
// Virtual Network
// -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.class_name}-${var.student_name}-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}

// -----------------------------------------------------------------------------
// Subnet (with service endpoints for Storage + SQL)
// -----------------------------------------------------------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.class_name}-${var.student_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql"
  ]
}

// -----------------------------------------------------------------------------
// Storage Account
// -----------------------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  name                     = "sto${var.class_name}${var.student_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

// -----------------------------------------------------------------------------
// Azure SQL Server (MSSQL)
// -----------------------------------------------------------------------------
resource "azurerm_mssql_server" "sql_server" {
  name                = "sqlsrv-${var.class_name}-${var.student_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"

  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  minimum_tls_version = "1.2"

  tags = local.tags
}

// -----------------------------------------------------------------------------
// Azure SQL Database (MSSQL)
// -----------------------------------------------------------------------------
resource "azurerm_mssql_database" "sql_db" {
  name      = "sqldb-${var.class_name}-${var.student_name}-${var.environment}"
  server_id = azurerm_mssql_server.sql_server.id

  sku_name    = "S0"
  max_size_gb = 10

  tags = local.tags
}
