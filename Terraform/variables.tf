variable "location" {
  description = "Azure Location name"
  default     = "westeurope"
}

variable "acr_name" {
  description = "Name for the Azure Container Registry. Must be globally unique."
  type        = string
  default     = "mahbubrahmanacr"
}