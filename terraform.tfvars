# AKS parameters
location                            = "eastus2"
prefix_name                         = "demoaks"
aks_agent_count                     = 3
aks_agent_vm_size                   = "Standard_D2_v2"
aks_kubernetes_version              = "1.14.6"

# AKS service network parameters
aks_service_cidr                    = "10.200.0.0/16"
aks_dns_service_ip                  = "10.200.0.10"
aks_docker_bridge_cidr              = "172.17.0.1/16"

# Virtual Network parameters

virtual_network_address_prefix      = "10.0.0.0/16"
aks_subnet_name                     = "aks-subnet"
aks_subnet_address_prefix           = "10.0.0.0/17"
app_gateway_subnet_name             = "agw-subnet"
app_gateway_subnet_address_prefix   = "10.0.130.0/24"

# Azure subscription ID and tenant ID to create resources
subscription_id                     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
tenant_id                           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Azure AD Service Principal to run Terraform (requires Owner Role). 
# To create, run: az ad sp create-for-rbac --role="Owner" --scopes="/subscription_ids/<YOUR_SUBSCRIPTION_ID>"
client_id                           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
client_secret                       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 

# Application Gateway parameters
app_gateway_sku                     = "Standard_v2"
app_gateway_tier                    = "Standard_v2"
app_gateway_min_capacity            = 2
app_gateway_max_capacity            = 10

# Certificate to import to Application Gateway parameters
# The certificate should be in the same directory or include the path
certificate_name                    = "appgw"
certificate_path                    = "appgw.pfx"
certificate_pwd                     = "Azure123456!"

# MySQL parameters
mysql_db_name                       = "exampledb"
mysql_admin_login                   = "mysqladminun"
mysql_admin_pwd                     = "Azure123456!"
mysql_version                       = "5.7"
mysql_vnetRule                      = "mysql-vnet-rule"
mysql_ssl_enforcement               = "Disabled"
mysql_sku_name                      = "GP_Gen5_2"
mysql_sku_capacity                  = 2
mysql_sku_tier                      = "GeneralPurpose"
mysql_sku_family                    = "Gen5"
mysql_storage_mb                    = 5120
mysql_backup_retention_days         = 7
mysql_geo_redundant_backup          = "Disabled"
