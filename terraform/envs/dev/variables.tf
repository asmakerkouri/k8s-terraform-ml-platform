variable "region" {
  description = "AWS region (Paris by default)"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  type    = string
  default = "dev"
}
