resource "random_pet" "prefix" {}
provider "azurerm" {
    features { 
    }
}

data "azurerm_kubernetes_cluster" "k8s_cluster_data" {
  name                = azurerm_kubernetes_cluster.k8s.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a resource group to contain all the objects
resource "azurerm_resource_group" "rg" {
  name     = "${var.azure_rg_name}-${join("", split(":", timestamp()))}" #Removing the colons since Azure doesn't allow them.
  location = var.azure_region
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 5
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }
  tags = {
    "Environment" = "Prod",
    "ApplicationNanme" = "my-app"
  }
}
#create a public IP address for the virtual machine
resource "azurerm_public_ip" "k8s-cluster-pubip" {
  name                = "k8s-cluster-pubip"
  location            = var.azure_region
  resource_group_name = data.azurerm_kubernetes_cluster.k8s_cluster_data.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "k8s-cluster-${lower(substr(join("", split(":", timestamp())), 8, -1))}"

}

resource "null_resource" "get_cluster_creds" {
  provisioner "local-exec" {
    # This will fetch the kube config
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.k8s.name}"
  }
}