variable "tag_class" {
  type    = string
  default = "dsba6190"
}

variable "tag_instructor" {
  type    = string
  default = "cford38"
}

variable "tag_semester" {
  type    = string
  default = "fall2024"
}

variable "location" {
  description = "Location of Resource Group"
  type        = string
  default     = "eastus"

  validation {
    condition     = contains(["eastus"], lower(var.location))
    error_message = "Unsupported Azure Region specified."
  }
}

// Azure-Specific App Variables

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "student_name" {
  description = "Application Name"
  type        = string
  default     = "gowri"
}

variable "class_name" {
  description = "Application Name"
  type        = string
  default     = "dsba6190"
}

# 🔹 ADD THESE:
variable "sql_admin_username" {
  description = "Administrator username for the Azure SQL Server"
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Administrator password for the Azure SQL Server"
  type        = string
  sensitive   = true
  default     = "SomeP@ssword1234!" # change if your instructor wants something else
}
