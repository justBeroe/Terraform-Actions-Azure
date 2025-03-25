variable "resource_group_name" {

  description = "The name of the resource group"
  type        = string

}
variable "resource_group_location" {

  description = "The location of the resource group"
  type        = string

}
variable "app_service_plan_name" {

  description = "The name of the app service"
  type        = string

}
variable "app_service_name" {

  description = "The name of the app"
  type        = string

}
variable "sql_server_name" {

  description = "The name of the SQL servier"
  type        = string

}
variable "sql_database_name" {

  description = "The name of SQL database"
  type        = string

}
variable "sql_user" {

  description = "SQL user"
  type        = string

}
variable "sql_user_pass" {

  description = "The password of SQL user"
  type        = string

}
variable "firewall_rule_name" {

  description = "The name of the firewall rule"
  type        = string

}
variable "github_repo" {

  description = "The location of the GitHub repo"
  type        = string

}
