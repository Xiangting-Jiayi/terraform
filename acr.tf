terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.57.0"
    }
  }
}

# Configure the Microsoft Azure Providers
provider "azurerm" {
  features {}

  client_id       = "1a55de5f-a723-407b-88b6-cecbd5dc5cd7"
  client_secret   = "orB8Q~j~Mal4S43DJcoWzlKABXu9JYXL5hZ_ZcaE"
  tenant_id       = "e1b8cf72-2e0b-4184-8c37-1558b754df8f"
  subscription_id = "060930ed-e1cf-46de-b013-d9841cb45729"
}

resource "azurerm_resource_group" "mfc_yoda_rg_acr" {
  name     = "MfcYodaRGAcr"
  location = "East Asia"
}



resource "azurerm_virtual_network" "mfc_yoda_vn_acr" {
  name                = "MfcYodaVirtualNetworkAcr"
  resource_group_name = azurerm_resource_group.mfc_yoda_rg_acr.name
  location            = azurerm_resource_group.mfc_yoda_rg_acr.location
  address_space       = ["10.234.0.0/16"]
}

resource "azurerm_subnet" "mfc_yoda_subnet_acr" {
  name                 = "MfcYodaSubnetAcr"
  resource_group_name  = azurerm_resource_group.mfc_yoda_rg_acr.name
  virtual_network_name = azurerm_virtual_network.mfc_yoda_vn_acr.name
  address_prefixes     = ["10.234.1.0/24"]
}




resource "azurerm_container_registry" "mfc_yoda_acr" {
  name                          = "MfcYodaAcr"
  resource_group_name           = azurerm_resource_group.mfc_yoda_rg_acr.name
  location                      = azurerm_resource_group.mfc_yoda_rg_acr.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  georeplications {
    location                = "southeastasia"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}

resource "azurerm_private_endpoint" "mfc_yoda_pe_acr" {
  name                = "MfcYodaPrivateEndpointAcr"
  resource_group_name = azurerm_resource_group.mfc_yoda_rg_acr.name
  location            = azurerm_resource_group.mfc_yoda_rg_acr.location
  subnet_id           = azurerm_subnet.mfc_yoda_subnet_acr.id

  private_service_connection {
    name                           = "MfcYodaPrivateServiceConnectionAcr"
    private_connection_resource_id = azurerm_container_registry.mfc_yoda_acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}

resource "azurerm_container_registry_scope_map" "mfc_yoda_acr_sm_devops_admin" {
  name                    = "MfcYodaAcrSMDevopsAdmin"
  container_registry_name = azurerm_container_registry.mfc_yoda_acr.name
  resource_group_name     = azurerm_resource_group.mfc_yoda_rg_acr.name
  actions = [
    "repositories/devops/content/read",
    "repositories/devops/content/write",
    "repositories/devops/content/delete"
  ]
}

resource "azurerm_container_registry_token" "mfc_yoda_acr_token_devops_admin" {
  name                    = "MfcYodaAcrTokenDevopsAdmin"
  container_registry_name = azurerm_container_registry.mfc_yoda_acr.name
  resource_group_name     = azurerm_resource_group.mfc_yoda_rg_acr.name
  scope_map_id            = azurerm_container_registry_scope_map.mfc_yoda_acr_sm_devops_admin.id
}

resource "azurerm_container_registry_token_password" "mfc_yoda_acr_token_password_devops_admin" {
  container_registry_token_id = azurerm_container_registry_token.mfc_yoda_acr_token_devops_admin.id

  password1 {
    expiry = "2023-12-22T17:57:36+08:00"
  }
}

resource "azurerm_container_registry_scope_map" "mfc_yoda_acr_sm_devops_read" {
  name                    = "MfcYodaAcrSMDevopsRead"
  container_registry_name = azurerm_container_registry.mfc_yoda_acr.name
  resource_group_name     = azurerm_resource_group.mfc_yoda_rg_acr.name
  actions = [
    "repositories/devops/content/read",
  ]
}

resource "azurerm_container_registry_token" "mfc_yoda_acr_token_devops_read" {
  name                    = "MfcYodaAcrTokenDevopsRead"
  container_registry_name = azurerm_container_registry.mfc_yoda_acr.name
  resource_group_name     = azurerm_resource_group.mfc_yoda_rg_acr.name
  scope_map_id            = azurerm_container_registry_scope_map.mfc_yoda_acr_sm_devops_read.id
}

resource "azurerm_container_registry_token_password" "mfc_yoda_acr_token_password_devops_read" {
  container_registry_token_id = azurerm_container_registry_token.mfc_yoda_acr_token_devops_read.id

  password1 {
    expiry = "2023-12-22T17:57:36+08:00"
  }
}

resource "azurerm_container_registry_scope_map" "mfc_yoda_acr_sm_devops_write" {
  name                    = "MfcYodaAcrSMDevopsWrite"
  container_registry_name = azurerm_container_registry.mfc_yoda_acr.name
  resource_group_name     = azurerm_resource_group.mfc_yoda_rg_acr.name
  actions = [
    "repositories/devops/content/write",
  ]
}

resource "azurerm_container_registry_token" "mfc_yoda_acr_token_devops_write" {
  name                    = "MfcYodaAcrTokenDevopsWrite"
  container_registry_name = azurerm_container_registry.mfc_yoda_acr.name
  resource_group_name     = azurerm_resource_group.mfc_yoda_rg_acr.name
  scope_map_id            = azurerm_container_registry_scope_map.mfc_yoda_acr_sm_devops_write.id
}

resource "azurerm_container_registry_token_password" "mfc_yoda_acr_token_password_devops_write" {
  container_registry_token_id = azurerm_container_registry_token.mfc_yoda_acr_token_devops_write.id

  password1 {
    expiry = "2023-12-22T17:57:36+08:00"
  }
}

resource "azurerm_role_assignment" "mfc_yoda_ra_acr_jenkins" {
  scope                = azurerm_container_registry.mfc_yoda_acr.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_virtual_machine.mfc_yoda_vm_jenkins_slave.identity.0.principal_id
}

resource "azurerm_resource_group" "mfc_yoda_rg_jenkins" {
  name     = "MfcYodaRGJenkins"
  location = "East Asia"
}

resource "azurerm_virtual_network" "mfc_yoda_vn_jenkins" {
  name                = "MfcYodaVirtualNetworkJenkins"
  resource_group_name = azurerm_resource_group.mfc_yoda_rg_jenkins.name
  location            = azurerm_resource_group.mfc_yoda_rg_jenkins.location
  address_space       = ["10.235.0.0/16"]
}

resource "azurerm_subnet" "mfc_yoda_subnet_jenkins" {
  name                 = "MfcYodaSubnetJenkins"
  resource_group_name  = azurerm_resource_group.mfc_yoda_rg_jenkins.name
  virtual_network_name = azurerm_virtual_network.mfc_yoda_vn_jenkins.name
  address_prefixes     = ["10.235.1.0/24"]
}

resource "azurerm_public_ip" "mfc_yoda_public_ip_jenkins_slave" {
  name                = "MfcYodaPublicIpJenkinsSlave"
  resource_group_name = azurerm_resource_group.mfc_yoda_rg_jenkins.name
  location            = azurerm_resource_group.mfc_yoda_rg_jenkins.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "mfc_yoda_ni_jenkins_slave" {
  name                = "MfcYodaNIJenkinsSlave-nic"
  location            = azurerm_resource_group.mfc_yoda_rg_jenkins.location
  resource_group_name = azurerm_resource_group.mfc_yoda_rg_jenkins.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mfc_yoda_subnet_jenkins.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mfc_yoda_public_ip_jenkins_slave.id
  }
}

resource "azurerm_network_security_group" "mfc_yoda_nsg_jenkins" {
  name                = "MfcYodaNSGRuleJenkins"
  location            = azurerm_resource_group.mfc_yoda_rg_jenkins.location
  resource_group_name = azurerm_resource_group.mfc_yoda_rg_jenkins.name

  security_rule {
    name                       = "MfcYodaNSGRuleVMSSHPublicAccess"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.235.1.0/24"
  }
}

resource "azurerm_network_interface_security_group_association" "mfc_yoda_nisga_jenkins" {
  network_interface_id      = azurerm_network_interface.mfc_yoda_ni_jenkins_slave.id
  network_security_group_id = azurerm_network_security_group.mfc_yoda_nsg_jenkins.id
}

resource "azurerm_virtual_machine" "mfc_yoda_vm_jenkins_slave" {
  name                = "MfcYodaVMJenkinsSlave"
  resource_group_name = azurerm_resource_group.mfc_yoda_rg_jenkins.name
  location            = azurerm_resource_group.mfc_yoda_rg_jenkins.location
  vm_size             = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.mfc_yoda_ni_jenkins_slave.id,
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "MfcYodaVMJenkinsSlave"
    admin_username = "devops"
    admin_password = "b1ueg1rL"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_virtual_network_peering" "mfc_yoda_vn_peering_jenkins_to_acr" {
  name                      = "MfcYodaVirtualNetworkPeeringJenkinsToAcr"
  resource_group_name       = azurerm_resource_group.mfc_yoda_rg_jenkins.name
  virtual_network_name      = azurerm_virtual_network.mfc_yoda_vn_jenkins.name
  remote_virtual_network_id = azurerm_virtual_network.mfc_yoda_vn_acr.id
}

resource "azurerm_virtual_network_peering" "mfc_yoda_vn_peering_acr_to_jenkins" {
  name                      = "MfcYodaVirtualNetworkPeeringJenkinsToAcr"
  resource_group_name       = azurerm_resource_group.mfc_yoda_rg_acr.name
  virtual_network_name      = azurerm_virtual_network.mfc_yoda_vn_acr.name
  remote_virtual_network_id = azurerm_virtual_network.mfc_yoda_vn_jenkins.id
}

