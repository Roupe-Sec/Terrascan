resource azurerm_kubernetes_cluster "k8s_cluster" {
  # Host disks are not encrypted 
  dns_prefix          = "test-${var.environment}"
  location            = var.location
  name                = "test-aks-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 2
  }
  addon_profile {
    oms_agent {
      enabled = false
    }
    kube_dashboard {
      enabled = true
    }
  }
  #checkov:skip=CKV_AZURE_4:Ignore logging errors
  role_based_access_control {
    enabled = false
  }  
}