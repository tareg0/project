
variable "region" {
    default = "eu-central-1"
}

variable "availability_zones_count" {
  default     = 3
}

variable "project" {
 default  = "my-EKS"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_bits" {
  default     = 8
}

variable "tags" {
  type        = map(string)
  default = {
    "Project"     = "TerraformEKSWorkshop"
    "Environment" = "Development"
    "Owner"       = "Taras Romanovskiy"
  }
}