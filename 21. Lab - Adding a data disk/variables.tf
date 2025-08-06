variable "vm_name" {
   type = string
   description = "This is the name for the virtual machine"
}

variable "admin_username" {
  type = string
  description = "This is the admin user name for the virtual machine"
}

variable "vm_size" {
  type = string
  description = "This is the size of the machine"
  default = "Standard_D2s_v5"  # Better performance than B-series for production workloads
}

variable "admin_password" {
  type = string
  description = "This is the admin password for the virtual machine"
  sensitive = true
}