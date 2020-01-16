variable "public_key_path" {
  description = "Path to the public SSH key you want to bake into the instance."
  default     = "~/.ssh/devopsTools.pub"
}

variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "~/.ssh/devopsTools"
}

variable "project_name" {
  description = "Name of your GCP project.  Example: 	devops-tools-263410"
  default     = "devops-tools-263410"
}

variable "ssh_user" {
  description = "SSH user name to connect to your instance."
  default     = "alexey"
}

variable "nested_vm_disk_name" {
  default     = "kvm-disk-terraform"
  description = "disk for kvm immage support"
}

variable "nested_vm_image_name" {
  default     = "kvm-image-terraform"
  description = "nested-vm-ubuntu-1804-image with installed selenoid-android"
}
