variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}"
}

variable "chef_channel" {
  default = "stable"
}

variable "chef_version" {
  default = "12.12.15"
}

variable "azure_location" {
  default = "East US"
}

variable "azure_image_urn" {
  type = "map"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2012-R2-Datacenter"
    version = "4.0.20160812"
  }
}

variable "custom_image_uri" {
  default = "https://learnchef852.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/learnchefwin-osDisk.65d15fbf-610d-4ebd-ab50-3d171617097c.vhd"
}

variable "azure_vm_size" {
  default = "Standard_D1"
}

variable "hostname" {
  default = "chef-azure"
}

variable "username" {
  default = "chef"
}

variable "password" {
  default = "P4ssw0rd!"
}


#resource "azurerm_resource_group" "test" {
#    name = "learnchefrg"
#    location = "${var.azure_location}"
#}
variable "resource_group_name" {
  default = "Learn-Chef"
}

resource "azurerm_virtual_network" "test" {
    name = "learnchefvn"
    address_space = ["10.0.0.0/16"]
    location = "${var.azure_location}"
    resource_group_name = "${var.resource_group_name}" #"${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
    name = "learnchefsub"
    resource_group_name = "${var.resource_group_name}" #"${azurerm_resource_group.test.name}"
    virtual_network_name = "${azurerm_virtual_network.test.name}"
    address_prefix = "10.0.2.0/24"
}

resource "azurerm_network_interface" "test" {
    name = "learnchefni"
    location = "${var.azure_location}"
    resource_group_name = "${var.resource_group_name}" #"${azurerm_resource_group.test.name}"

    ip_configuration {
        name = "learnchefipc"
        subnet_id = "${azurerm_subnet.test.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.test.id}"
    }
}

#resource "azurerm_storage_account" "test" {
#    name = "learnchefsa"
#    resource_group_name = "${var.resource_group_name}" #"${azurerm_resource_group.test.name}"
#    location = "${var.azure_location}"
#    account_type = "Standard_LRS"
#
#    tags {
#        environment = "staging"
#    }
#}
variable "storage_account_name" {
  default = "learnchef852"
}

resource "azurerm_storage_container" "test" {
    name = "learnchefvhds"
    resource_group_name = "${var.resource_group_name}" #"${azurerm_resource_group.test.name}"
    storage_account_name = "${var.storage_account_name}" #"${azurerm_storage_account.test.name}"
    container_access_type = "private"
}

resource "azurerm_public_ip" "test" {
    name = "learnchefpip"
    location = "${var.azure_location}"
    resource_group_name = "${var.resource_group_name}" #"${azurerm_resource_group.test.name}"
    public_ip_address_allocation = "static"

    tags {
        environment = "staging"
    }
}

resource "azurerm_virtual_machine" "test" {
    name = "${var.hostname}"
    location = "${var.azure_location}"
    resource_group_name = "${var.resource_group_name}" #"${azurerm_resource_group.test.name}"
    network_interface_ids = ["${azurerm_network_interface.test.id}"]
    vm_size = "Standard_D1"

    #storage_image_reference {
    #    publisher = "${lookup(var.azure_image_urn, "publisher")}"
    #    offer = "${lookup(var.azure_image_urn, "offer")}"
    #    sku = "${lookup(var.azure_image_urn, "sku")}"
    #    version = "${lookup(var.azure_image_urn, "version")}"
    #}

    storage_os_disk {
        name = "learnchefosdisk"
        # vhd_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/learnchefosdisk.vhd"
        vhd_uri = "https://learnchef852.blob.core.windows.net/${azurerm_storage_container.test.name}/learnchefosdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
        image_uri = "${var.custom_image_uri}"
        os_type = "windows"
    }

    os_profile {
        computer_name = "${var.hostname}"
        admin_username = "${var.username}"
        admin_password = "${var.password}"
    }

    #os_profile_linux_config {
  #    disable_password_authentication = true
  #    ssh_keys {
#        path = "/home/${var.username}/.ssh/authorized_keys"
#        key_data = "${file("~/.ssh/id_rsa.pub")}" # public key on local machine
#      }
#    }

    connection {
      type     = "winrm"
      host     = "${azurerm_public_ip.test.ip_address}"
      user     = "${var.username}"
      password = "${var.password}"
      insecure = true
    }

    tags {
      environment = "staging"
    }

    #provisioner "remote-exec" {
  #    script = "../../../shared/scripts/bootstrap-azure.ps1"
  #  }

    provisioner "file" {
      source = "vendored-cookbooks"
      destination = "C:\\Temp\\vendored-cookbooks"
    }

    provisioner "file" {
      source = "files/solo.rb"
      destination = "C:\\Temp\\solo.rb"
    }

    provisioner "file" {
        content = <<EOF
    {
      "run_list": [
        "recipe[learn_the_basics_windows]"
      ],
      "snippets": {
        "virtualization": "azure"
      },
      "cloud": {
        "azure": {
          "location": "${var.azure_location}",
          "node": {
            "image_urn": "${lookup(var.azure_image_urn, "publisher")}:${lookup(var.azure_image_urn, "offer")}:${lookup(var.azure_image_urn, "sku")}:${lookup(var.azure_image_urn, "version")}",
            "size": "${var.azure_vm_size}"
          }
        }
      }
    }
    EOF
      destination = "C:\\temp\\dna.json"
    }

    provisioner "file" {
      source = "../../../shared/scripts/SetupFTP.bat"
      destination = "C:\\Temp\\SetupFTP.bat"
    }

    provisioner "file" {
      source = "../../../shared/scripts/SetPath.ps1"
      destination = "C:\\Temp\\SetPath.ps1"
    }

    provisioner "file" {
      source = "../../../shared/scripts/RunChefSolo.bat"
      destination = "C:\\Temp\\RunChefSolo.bat"
    }

    provisioner "remote-exec" {
      inline = [
        "powershell.exe -ExecutionPolicy RemoteSigned -Command C:\\Temp\\SetPath.ps1",
        "powershell.exe -ExecutionPolicy RemoteSigned -Command \"& { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -channel ${var.chef_channel} -version ${var.chef_version}\"",
        "C:\\Temp\\RunChefSolo.bat",
        "C:\\Temp\\SetupFTP.bat ${azurerm_public_ip.test.ip_address}"
      ]
    }
}

output "ip_address" {
  value = "${azurerm_public_ip.test.ip_address}"
}
