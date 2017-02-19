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
    publisher = "canonical"
    offer = "UbuntuServer"
    sku = "14.04.5-LTS"
    version = "14.04.201608091"
  }
}

variable "azure_vm_size" {
  default = "Standard_D1"
}

variable "hostname" {
  default = "ubuntu-azure"
}

variable "username" {
  default = "chef"
}

variable "password" {
  default = "Password1234!"
}

resource "azurerm_resource_group" "test" {
    name = "learnchefrg"
    location = "${var.azure_location}"
}

resource "azurerm_virtual_network" "test" {
    name = "learnchefvn"
    address_space = ["10.0.0.0/16"]
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
    name = "learnchefsub"
    resource_group_name = "${azurerm_resource_group.test.name}"
    virtual_network_name = "${azurerm_virtual_network.test.name}"
    address_prefix = "10.0.2.0/24"
}

resource "azurerm_network_interface" "test" {
    name = "learnchefni"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"

    ip_configuration {
        name = "learnchefipc"
        subnet_id = "${azurerm_subnet.test.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.test.id}"
    }
}

resource "azurerm_storage_account" "test" {
    name = "learnchefsa"
    resource_group_name = "${azurerm_resource_group.test.name}"
    location = "${var.azure_location}"
    account_type = "Standard_LRS"

    tags {
        environment = "staging"
    }
}

resource "azurerm_storage_container" "test" {
    name = "learnchefvhds"
    resource_group_name = "${azurerm_resource_group.test.name}"
    storage_account_name = "${azurerm_storage_account.test.name}"
    container_access_type = "private"
}

resource "azurerm_public_ip" "test" {
    name = "learnchefpip"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    public_ip_address_allocation = "static"

    tags {
        environment = "staging"
    }
}

resource "azurerm_virtual_machine" "test" {
    name = "${var.hostname}"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    network_interface_ids = ["${azurerm_network_interface.test.id}"]
    vm_size = "Standard_D1"

    storage_image_reference {
        publisher = "${lookup(var.azure_image_urn, "publisher")}"
        offer = "${lookup(var.azure_image_urn, "offer")}"
        sku = "${lookup(var.azure_image_urn, "sku")}"
        version = "${lookup(var.azure_image_urn, "version")}"
    }

    storage_os_disk {
        name = "learnchefosdisk"
        vhd_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/learnchefosdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.hostname}"
        admin_username = "${var.username}"
        admin_password = "${var.password}"
    }

    os_profile_linux_config {
      disable_password_authentication = true
      ssh_keys {
        path = "/home/${var.username}/.ssh/authorized_keys"
        key_data = "${file("~/.ssh/id_rsa.pub")}" # public key on local machine
      }
    }

    connection {
      host     = "${azurerm_public_ip.test.ip_address}"
      user     = "${var.username}"
      key_file = "~/.ssh/id_rsa" # private key on my local machine
    }

    tags {
      environment = "staging"
    }

    provisioner "file" {
      source = "vendored-cookbooks"
      destination = "/tmp"
    }

    provisioner "file" {
      source = "files/solo.rb"
      destination = "/tmp/solo.rb"
    }

    provisioner "file" {
        content = <<EOF
    {
      "run_list": [
        "recipe[learn_the_basics_ubuntu]"
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
      destination = "/tmp/dna.json"
    }

    provisioner "remote-exec" {
      inline = [
        "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -c ${var.chef_channel} -v ${var.chef_version}",
        "sudo chef-solo -c /tmp/solo.rb -j /tmp/dna.json"
      ]
    }
}
