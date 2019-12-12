variable "location" {
  default = "eastus"
}

variable "mvp_name" {
  default = ""
}
variable "mvp_contact_email" {
  default = "devops-mtl@thalesdigital.io"
}

variable "mvp_budget_packet" {
  default = "10000"
}

variable "api_server_authorized_ip_ranges" {
  default = [""]
}
variable "node_resource_group" {
  default = "node"
}

variable "resource_group_name_dns" {
  default = "dns"
}

variable "vm_size" {
  type = map

  default = {

    default = "Standard_DS4_v2"

  }
}

variable "azure_client_id" {
  default = ""
}

variable "azure_client_secret" {
  type = string
}

variable "tenant_id" {
  default = ""
}

variable "subscription_id" {
  default = ""
}

variable "agent_count" {
  type = map

  default = {
    default      = 4
    new-customer = 2

  }
}
variable "max_count" {
  type = map
  default = {
    default      = 5
    new-customer = 2
  }
}
variable "min_count" {
  type = map
  default = {
    default      = 4
    new-customer = 2
  }
}
variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable kubernetes_version {
  default = "1.14.8"
}

variable "tiller_version" {
  type        = string
  default     = "v2.15.1"
  description = "Version of Tiller to be deployed."
}

variable "tiller_namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace to deploy Tiller into."
}

variable "helm" {
  type        = map
  description = "Helm provider parameters"
  default     = {}
}


