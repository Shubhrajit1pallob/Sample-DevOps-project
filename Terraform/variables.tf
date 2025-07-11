variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "private_key" {
  description = "The private key for SSH access to the instance"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair to use for the instance"
  type        = string
  default     = "deployer_key"
}

variable "public_key" {
  description = "The public key for SSH access to the instance"
  type        = string
}