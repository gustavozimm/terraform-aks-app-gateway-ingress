# Configure the Microsoft Azure Provider.
provider "azurerm" {
  version         = ">=1.34.0"
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

data "azurerm_subscription" "main" {
}

# Terraform backend config for Remote State in Azure Storage Account
# If you don't have, create running (replace values accord you preferences):
# az group create --name TerraformState-RG --location eastus2
# az storage account create --name <INSERT_NAME> --resource-group <INSERT_RG_NAME> --sku Standard_LRS
terraform {
  backend "azurerm" {
    resource_group_name  = "TERRAFORM_STORAGE_GROUP_RG"
    storage_account_name = "TERRAFORM_STORAGE_GROUP_NAME"
    container_name       = "terraformstate"
    key                  = "state.tfstate"
  }
}

#create resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix_name}-rg"
  location = var.location
}

provider "random" {
  version = ">=2.2"
}

resource "random_id" "main" {
  byte_length = 4
}

# Generate random string to be used for Service Principal password
resource "random_string" "main" {
  length  = 32
  upper   = true
  special = true
  lower   = true
  number  = true
}

provider "azuread" {
  version = ">=0.6"
}


resource "azuread_application" "agw" {
  name                       = "${var.prefix_name}-${random_id.main.hex}-agw"
  available_to_other_tenants = false
}

resource "azuread_service_principal" "agw" {
  application_id               = azuread_application.agw.application_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "agw" {
  application_object_id = azuread_application.agw.id
  value                 = random_string.main.result
  end_date              = "2220-01-01T01:02:03Z"
}

resource "azuread_service_principal_password" "agw" {
  service_principal_id = azuread_service_principal.agw.id
  value                = random_string.main.result
  end_date             = "2220-01-01T01:02:03Z"
}

resource "azurerm_role_assignment" "agw" {
  scope                = data.azurerm_subscription.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.agw.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.virtual_network_address_prefix]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet_aks" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = var.aks_subnet_name
  address_prefix       = var.aks_subnet_address_prefix
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "subnet_app_gateway" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = var.app_gateway_subnet_name
  address_prefix       = var.app_gateway_subnet_address_prefix
}

resource "azurerm_public_ip" "agw_public_ip" {
  name                         = "${var.prefix_name}-public-ip"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = var.app_gateway_public_ip_address_allocation
  sku                          = var.app_gateway_public_ip_sku
  tags                         = var.tags
}

resource "azurerm_application_gateway" "agw" {
  name                = "${var.prefix_name}-app-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = var.app_gateway_sku
    tier = var.app_gateway_tier
  }

  autoscale_configuration {
    min_capacity = var.app_gateway_min_capacity
    max_capacity = var.app_gateway_max_capacity
  }

  ssl_certificate {
    name     = var.certificate_name
    data     = filebase64(var.certificate_path)
    password = var.certificate_pwd
  }

  gateway_ip_configuration {
    name      = azurerm_subnet.subnet_app_gateway.name
    subnet_id = azurerm_subnet.subnet_app_gateway.id
  }

  frontend_port {
    name = "${azurerm_virtual_network.vnet.name}-feport"
    port = 80
  }

  frontend_port {
    name = "https_port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${azurerm_virtual_network.vnet.name}-feip"
    public_ip_address_id = azurerm_public_ip.agw_public_ip.id
  }

  backend_address_pool {
    name = "${azurerm_virtual_network.vnet.name}-beap"
  }

  backend_http_settings {
    name                  = "${azurerm_virtual_network.vnet.name}-be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "http"
    request_timeout       = 1
  }

  http_listener {
    name                           = "${azurerm_virtual_network.vnet.name}-httplstn"
    frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
    frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
    protocol                       = "http"
  }

  request_routing_rule {
    name                       = "${azurerm_virtual_network.vnet.name}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = "${azurerm_virtual_network.vnet.name}-httplstn"
    backend_address_pool_name  = "${azurerm_virtual_network.vnet.name}-beap"
    backend_http_settings_name = "${azurerm_virtual_network.vnet.name}-be-htst"
  }

  tags = var.tags
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_public_ip.agw_public_ip,
  ]
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix_name}-aks"
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix_name}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = var.aks_kubernetes_version
  role_based_access_control {
    enabled = var.aks_enable_rbac
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }
  
  agent_pool_profile {
    name                = var.aks_agent_pool_name
    count               = var.aks_agent_count
    vm_size             = var.aks_agent_vm_size
    #availability_zones  = ["1", "2", "3"]
    max_pods            = var.aks_agent_pool_max_pods
    os_disk_size_gb     = var.aks_agent_os_disk_size
    os_type             = var.aks_agent_pool_os_type
    type                = var.aks_agent_pool_type
    vnet_subnet_id      = azurerm_subnet.subnet_aks.id
  }

  service_principal {
    client_id     = azuread_service_principal.agw.application_id
    client_secret = random_string.main.result
  }

  depends_on = [
    azurerm_virtual_network.vnet,
    azuread_application.agw,
    azuread_service_principal.agw,
    azuread_service_principal_password.agw,
    azuread_application_password.agw,
    azurerm_role_assignment.agw,
  ]
  tags = var.tags
}

resource "azurerm_mysql_server" "mysql_server" {
  name                = "${var.prefix_name}-db"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = var.mysql_sku_name
    capacity = var.mysql_sku_capacity
    tier     = var.mysql_sku_tier
    family   = var.mysql_sku_family
  }

  storage_profile {
    storage_mb            = var.mysql_storage_mb
    backup_retention_days = var.mysql_backup_retention_days
    geo_redundant_backup  = var.mysql_geo_redundant_backup
  }

  administrator_login          = var.mysql_admin_login
  administrator_login_password = var.mysql_admin_pwd
  version                      = var.mysql_version
  ssl_enforcement              = var.mysql_ssl_enforcement
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = var.mysql_db_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_virtual_network_rule" "mysql_service_endpoint" {
  name                = var.mysql_vnetRule
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql_server.name
  subnet_id           = azurerm_subnet.subnet_aks.id
}

# Initialize kubernetes provider to access new deployed cluster
provider "kubernetes" {
  version           = ">=1.9"
  load_config_file  = false
  host              = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  username          = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  password          = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  client_certificate = base64decode(
    azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate,
    )
  client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(
    azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate,
    )
}

# Create User Assigned Identities 
resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  location            = azurerm_resource_group.rg.location
  name                = var.identity_name
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_kubernetes_cluster.k8s,
  ]
  tags = var.tags
}

resource "azurerm_role_assignment" "ra1" {
  scope                = azurerm_subnet.subnet_aks.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.agw.object_id
  depends_on = [
    azurerm_user_assigned_identity.identity,
    azurerm_virtual_network.vnet,
  ]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azuread_service_principal.agw.object_id
  depends_on           = [azurerm_user_assigned_identity.identity]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.agw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  depends_on = [
    azurerm_user_assigned_identity.identity,
    azurerm_application_gateway.agw,
  ]
}

resource "azurerm_role_assignment" "ra4" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  depends_on = [
    azurerm_user_assigned_identity.identity,
    azurerm_application_gateway.agw,
  ]
}

resource "kubernetes_storage_class" "pvc" {
  metadata {
    name = "${var.prefix_name}-storage"
  }
  storage_provisioner = "kubernetes.io/azure-file"
  reclaim_policy      = "Delete"
  parameters = {
    skuName = "Standard_LRS"
  }
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_role_assignment.ra3,
  ]
}

resource "kubernetes_cluster_role" "pvc" {
  metadata {
    name = "system:azure-cloud-provider"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create"]
  }
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_role_assignment.ra3,
  ]
}

resource "kubernetes_cluster_role_binding" "pvc" {
  metadata {
    name = "system:azure-cloud-provider"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:azure-cloud-provider"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "persistent-volume-binder"
  }
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_role_assignment.ra3,
  ]
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name = "${var.prefix_name}-storage"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "${var.prefix_name}-storage"
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_role_assignment.ra3,
  ]
}

provider "null" {
  version = ">=2.1"
}


resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.prefix_name}-rg --name ${var.prefix_name}-aks --overwrite-existing && kubectl apply -f deployment.yaml" # && kubectl create namespace wavy-whatsapp && kubectl create secret tls wavy-global --key wildcard_wavy_global.key --cert wildcard_wavy_global.crt -n wavy-whatsapp"
  }
  depends_on = [
    kubernetes_storage_class.pvc,
    kubernetes_cluster_role.pvc,
    kubernetes_cluster_role_binding.pvc,
    kubernetes_persistent_volume_claim.pvc
  ]
}

# initialize helm provider to access new deployed cluster
provider "helm" {
  version        = ">=0.9"
  install_tiller = true
   kubernetes {
    load_config_file  = false
    host              = azurerm_kubernetes_cluster.k8s.kube_config[0].host
    client_certificate = base64decode(
      azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate,
      )
    client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(
      azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate,
      )
  } 
}

data "helm_repository" "helm_appgw" {
  name = "application-gateway-kubernetes-ingress"
  url  = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
}

resource "helm_release" "agw_ingress" {
  name       = "application-gateway-kubernetes-ingress"
  repository = data.helm_repository.helm_appgw.name
  chart      = "ingress-azure"
  version    = "0.9.0"

  values = [
    <<EOF
verbosityLevel: 3
appgw:
    subscriptionId: ${var.subscription_id}
    resourceGroup: ${var.prefix_name}-rg
    name: ${var.prefix_name}-app-gateway
    shared: false
armAuth:
    type: aadPodIdentity
    identityResourceID: ${azurerm_user_assigned_identity.identity.id}
    identityClientID:  ${azurerm_user_assigned_identity.identity.client_id}
rbac:
    enabled: false 
aksClusterConfiguration:
    apiServerAddress: ${azurerm_kubernetes_cluster.k8s.kube_config[0].host}
EOF
    ,
  ]
  depends_on = [
    kubernetes_storage_class.pvc,
    kubernetes_cluster_role.pvc,
    kubernetes_cluster_role_binding.pvc,
    kubernetes_persistent_volume_claim.pvc,
    null_resource.main
  ]
}

# resource "kubernetes_secret" "main" {
#   metadata {
#     name = "wavy-global"
#     }
#   data = {
#     "tls.crt" = "bu" #"${var.site_certificate}"
#     "tls.key" = "bu" #"${var.site_certificate_key}"
#   }
#   type  = "kubernetes.io/tls"
# }
