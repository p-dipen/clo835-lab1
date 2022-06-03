

variable "num_linux_vms" {
  default     = 1
  description = "Number of Linux VMs to provision"
  type        = number
}

variable "vm_instance_type" {
  default     = "t2.micro"
  description = "Instance type to use"
  type        = string
}

variable "path_to_linux_key" {
  default     = "/home/ec2-user/.ssh/linux.pub"
  description = "Path to the public key to use in Linux VMs provisioning"
  type        = string
}
