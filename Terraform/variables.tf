variable "location" {
  description = "Azure Location name"
  default     = "westeurope"
}

variable "acr_name" {
  description = "Name for the Azure Container Registry. Must be globally unique."
  type        = string
  default     = "mahbubrahmanacr"
}

# variable "tags" {
#   description = "The default tags to associate with resources."
#   type        = map(string)
# }

# variable "aks_config" {
#   description = "AKS Configuration"
# }

# variable "app_gtw_config" {
#   description = "Application Gateway Configuration"
# }