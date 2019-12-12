resource "azurerm_resource_group" "k8s" {
  name     = "${var.mvp_name}-${terraform.workspace}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                            = "k8s-${var.mvp_name}-${terraform.workspace}"
  location                        = azurerm_resource_group.k8s.location
  resource_group_name             = azurerm_resource_group.k8s.name
  dns_prefix                      = "${var.mvp_name}-${terraform.workspace}"
  kubernetes_version              = var.kubernetes_version
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  node_resource_group             = "${terraform.workspace}-${var.node_resource_group}"

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name                = "agentpool"
    vm_size             = lookup(var.vm_size, terraform.workspace)
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    availability_zones  = [1, 2, 3]
    node_count          = lookup(var.agent_count, terraform.workspace)
    min_count           = lookup(var.min_count, terraform.workspace)
    max_count           = lookup(var.max_count, terraform.workspace)
  }


  service_principal {
    client_id     = var.azure_client_id
    client_secret = var.azure_client_secret
  }

  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials --resource-group "${azurerm_resource_group.k8s.name}" --name "k8s-${var.mvp_name}-${terraform.workspace}" --file admin-"${terraform.workspace}" --overwrite-existing && sleep 30 && export KUBECONFIG=admin-"${terraform.workspace}"
    EOT
  }

  tags = {
    mvp = "${var.mvp_name}-${terraform.workspace}"
    ctc = var.mvp_contact_email
    bud = var.mvp_budget_packet
  }
}

resource "azurerm_network_security_group" "k8s_sg" {
  name                = "${azurerm_resource_group.k8s.name}-sg"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name

  security_rule {
    name                       = "from-mtl-office"
    priority                   = 101
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_address_prefixes    = ["72.138.98.210"]
    source_port_range          = "*"
  }
}
