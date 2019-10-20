variable "location" {
  description = "Location of the cluster."
}

variable "prefix_name" {
  description = "Prefix Name for the deployment"
  default     = "aks"
}

variable "aks_agent_count" {
  description = "The number of agent nodes for the cluster."
  default     = 3
}

variable "aks_agent_vm_size" {
  description = "The size of the Virtual Machine."
  default     = "Standard_D3_v2"
}

variable "aks_kubernetes_version" {
  description = "The version of Kubernetes."
  default     = "1.14.6"
}

variable "aks_agent_pool_name" {
  description = "Agent pool name"
  default     = "agentpool"
}

variable "aks_agent_pool_os_type" {
  description = "Agent pool OS type"
  default     = "Linux"
}

variable "aks_agent_pool_type" {
  description = "Agent pool type"
  default     = "VirtualMachineScaleSets"
}

variable "aks_agent_pool_max_pods" {
  description = "Agent pool max pods"
  default     = 100
}

variable "aks_agent_os_disk_size" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize."
  default     = 40
}

variable "aks_service_cidr" {
  description = "A CIDR notation IP range from which to assign service cluster IPs."
  default     = "10.200.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "Containers DNS server IP address."
  default     = "10.200.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "A CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC on the AKS cluster. Defaults to false."
  default     = "false"
}

variable "subscription_id" {
  description = "Azure Subscription Id"
}

variable "tenant_id" {
  description = "Service Principal AD Tenant ID - Azure AD for terraform authentication"
}

variable "client_id" {
  description = "Service Principal App ID - Azure AD for terraform authentication"
}

variable "client_secret" {
  description = "Service Principal Client Secret - Azure AD for terraform authentication"
}

variable "virtual_network_name" {
  description = "Virtual network name"
  default     = "vnet"
}

variable "virtual_network_address_prefix" {
  description = "Containers DNS server IP address."
  default     = "10.0.0.0/16"
}

variable "aks_subnet_name" {
  description = "AKS Subnet Name."
  default     = "aks-subnet"
}

variable "aks_subnet_address_prefix" {
  description = "Containers DNS server IP address."
  default     = "10.1.0.0/17"
}

variable "app_gateway_subnet_name" {
  description = "App Gateway Subnet Name."
  default     = "agw-subnet"
}

variable "app_gateway_subnet_address_prefix" {
  description = "Containers DNS server IP address."
  default     = "10.100.0.0/24"
}

variable "app_gateway_public_ip_name" {
  description = "App Gateway Public Ip Name."
  default     = "agw-public-ip"
}

variable "app_gateway_public_ip_address_allocation" {
  description = "App Gateway Public Ip Address Allocation Type."
  default     = "Static"
}

variable "app_gateway_public_ip_sku" {
  description = "App Gateway Public Ip Sku."
  default     = "Standard"
}

variable "app_gateway_sku" {
  description = "Name of the Application Gateway SKU."
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  description = "Tier of the Application Gateway SKU."
  default     = "Standard_v2"
}

variable "app_gateway_min_capacity" {
  description = "Application Gateway Minimun Capacity."
  default     = 2
}

variable "app_gateway_max_capacity" {
  description = "Application Gateway Maximum Capacity."
  default     = 10
}

variable "certificate_name" {
  description = "Name of the certificate to import to Application Gateway."
}

variable "certificate_path" {
  description = "Path of the certificate to import to Application Gateway."
}

variable "certificate_pwd" {
  description = "Password of the certificate to import to Application Gateway."
}

variable "mysql_admin_login" {
  description = "MySQL Admin login name."
}

variable "mysql_admin_pwd" {
  description = "MySQL Admin login password."
}

variable "mysql_db_name" {
  description = "MySQL initial database name."
}

variable "mysql_version" {
  description = "MySQL server version."
}

variable "mysql_vnetRule" {
  description = "MySQL VNet rule name."
}

variable "mysql_ssl_enforcement" {
  description = "MySQL enforce SSL."
}

variable "mysql_sku_name" {
  description = "MySQL SKU name."
}

variable "mysql_sku_capacity" {
  description = "MySQL Capacity name."
}

variable "mysql_sku_tier" {
  description = "MySQL Tier."
}

variable "mysql_sku_family" {
  description = "MySQL SKU Family."
}

variable "mysql_storage_mb" {
  description = "MySQL Initial Storage."
}

variable "mysql_backup_retention_days" {
  description = "MySQL backup retention period (days)."
}

variable "mysql_geo_redundant_backup" {
  description = "MySQL geo redundant backup."
}

variable "identity_name" {
  description = "Identity used by AKS to create rules on App Gateway"
  default     = "identity1"
}

variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
  }
}

