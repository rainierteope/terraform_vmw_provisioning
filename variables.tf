variable "datacenter" {
  type        = string
  description = "Name of the virtual datacenter"
}

variable "cluster" {
  type        = string
  description = "Name of the cluster"
}

variable "datastore" {
  type        = string
  description = "Name of the datastore"
}

variable "host" {
  type        = string
  default     = null
  description = "Name of the esxi host"
}

variable "folder" {
  default = null
}

variable "networks" {
  type        = list(string)
  description = "List of port groups and IP addresses for each VM"
}

variable "template" {
  type        = string
  description = "Name of the VM template"
}

variable "instances" {
  type        = number
  default     = 1
  description = "Number of VM to provision"
}

variable "name" {
  type        = string
  description = "Name of the VMs"
}

variable "size" {
  type        = string
  default     = "small"
  description = "Size of the virtual machine"
}

variable "disks" {
  type        = list(number)
  description = "List of virtual disks and their sizes"
}

variable "ipv4_gateway" {
  type        = string
  description = "IPv4 gateway of the virtual machines"
}

variable "dns_server_list" {
  type        = list(string)
  description = "List of DNS servers of the VMs"
}

variable "domain" {
  type        = string
  description = "Domain of the virtual machines"
  default     = "localdomain.local"
}

variable "isWindows" {
  type        = bool
  description = "Boolean variable to set if the image is a Windows image"
  default     = false
}