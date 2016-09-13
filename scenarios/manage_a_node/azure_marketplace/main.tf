variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "key_name" {}
variable "ssh_key_file" {}

variable "chef_client_channel" {
  default = "stable"
}

variable "chef_client_version" {
  default = "12.12.15"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}"
}

variable "azure_location" {
  default = "East US"
}

variable "chef_server_image_urn" {
  type = "map"
  default = {
    publisher = "chef-software"
    offer = "chef-server"
    sku = "azure_marketplace_25"
    version = "3.1.0"
  }
}

variable "workstation_image_urn" {
  type = "map"
  default = {
    publisher = "canonical"
    offer = "UbuntuServer"
    sku = "14.04.4-LTS"
    version = "14.04.201607140"
  }
}

variable "node1_image_urn" {
  type = "map"
  default = {
    publisher = "openlogic"
    offer = "centos"
    sku = "7.2n"
    version = "7.2.20160629"
  }
}

variable "chef_server_vm_size" {
  default = "Standard_D2_v2"
}

variable "chef_server_hostname" {
  default = "chef-server-azure"
}

variable "node1_hostname" {
  default = "node1-azure"
}

variable "workstation_hostname" {
  default = "workstation-azure"
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

resource "azurerm_network_interface" "chef_server" {
    name = "learnchefni_chef_server"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"

    ip_configuration {
        name = "learnchefipc_chef_server"
        subnet_id = "${azurerm_subnet.test.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.chef_server.id}"
    }
}

resource "azurerm_network_interface" "workstation" {
    name = "learnchefni_workstation"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"

    ip_configuration {
        name = "learnchefipc_workstation"
        subnet_id = "${azurerm_subnet.test.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.workstation.id}"
    }
}

resource "azurerm_network_interface" "node1" {
    name = "learnchefni_node1"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"

    ip_configuration {
        name = "learnchefipc_node1"
        subnet_id = "${azurerm_subnet.test.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.node1.id}"
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

resource "azurerm_public_ip" "chef_server" {
    name = "learnchefpip_chef_server"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    public_ip_address_allocation = "static"
    domain_name_label = "learn-chef-server"

    tags {
        environment = "staging"
    }
}

resource "azurerm_public_ip" "workstation" {
    name = "learnchefpip_workstation"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    public_ip_address_allocation = "static"

    tags {
        environment = "staging"
    }
}

resource "azurerm_public_ip" "node1" {
    name = "learnchefpip_node1"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    public_ip_address_allocation = "static"

    tags {
        environment = "staging"
    }
}

resource "azurerm_virtual_machine" "chef_server" {
    name = "${var.chef_server_hostname}"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    network_interface_ids = ["${azurerm_network_interface.chef_server.id}"]
    vm_size = "${var.chef_server_vm_size}"

    storage_image_reference {
        publisher = "${lookup(var.chef_server_image_urn, "publisher")}"
        offer = "${lookup(var.chef_server_image_urn, "offer")}"
        sku = "${lookup(var.chef_server_image_urn, "sku")}"
        version = "${lookup(var.chef_server_image_urn, "version")}"
    }

    plan {
        publisher = "${lookup(var.chef_server_image_urn, "publisher")}"
        product = "${lookup(var.chef_server_image_urn, "offer")}"
        name = "${lookup(var.chef_server_image_urn, "sku")}"
    }

    storage_os_disk {
        name = "learnchefosdisk_chef_server"
        vhd_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/learnchefosdisk_chef_server.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.chef_server_hostname}"
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
      host     = "${azurerm_public_ip.chef_server.ip_address}"
      user     = "${var.username}"
      key_file = "~/.ssh/id_rsa" # private key on my local machine
    }

    tags {
      environment = "staging"
    }

    provisioner "remote-exec" {
      inline = [
        "mkdir ~/drop",
        "ls /idontexist",
        "while [ $? -ne 0 ]; do sleep 1m && tail /var/log/cloud-init-output.log | grep 'finished at'; done;",
        "sudo rm /var/opt/opscode/nginx/etc/nginx.d/analytics.conf",
        "echo 'api_fqdn \"${azurerm_public_ip.chef_server.fqdn}\"' | sudo tee -a /etc/chef-marketplace/marketplace.rb",
        "sudo chef-marketplace-ctl hostname ${azurerm_public_ip.chef_server.fqdn}",
        "sudo opscode-analytics-ctl reconfigure",
        "sudo chef-server-ctl user-create admin Bob Admin admin@4thcoffee.com insecurepassword --filename ~/drop/admin.pem",
        "sudo chef-server-ctl org-create 4thcoffee \"Fourth Coffee, Inc.\" --association_user admin --filename 4thcoffee-validator.pem"
      ]
    }
}


resource "azurerm_virtual_machine" "node1" {
    name = "${var.node1_hostname}"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    network_interface_ids = ["${azurerm_network_interface.node1.id}"]
    vm_size = "Standard_D1"

    storage_image_reference {
        publisher = "${lookup(var.node1_image_urn, "publisher")}"
        offer = "${lookup(var.node1_image_urn, "offer")}"
        sku = "${lookup(var.node1_image_urn, "sku")}"
        version = "${lookup(var.node1_image_urn, "version")}"
    }

    storage_os_disk {
        name = "learnchefosdisk_node1"
        vhd_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/learnchefosdisk_node1.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.node1_hostname}"
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
}

resource "azurerm_virtual_machine" "workstation" {
    name = "${var.workstation_hostname}"
    location = "${var.azure_location}"
    resource_group_name = "${azurerm_resource_group.test.name}"
    network_interface_ids = ["${azurerm_network_interface.workstation.id}"]
    vm_size = "Standard_D1"

    storage_image_reference {
        publisher = "${lookup(var.workstation_image_urn, "publisher")}"
        offer = "${lookup(var.workstation_image_urn, "offer")}"
        sku = "${lookup(var.workstation_image_urn, "sku")}"
        version = "${lookup(var.workstation_image_urn, "version")}"
    }

    storage_os_disk {
        name = "learnchefosdisk_workstation"
        vhd_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/learnchefosdisk_workstation.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.workstation_hostname}"
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
      host     = "${azurerm_public_ip.workstation.ip_address}"
      user     = "${var.username}"
      key_file = "~/.ssh/id_rsa" # private key on my local machine
    }

    tags {
      environment = "staging"
    }

    provisioner "file" {
      source = "${var.ssh_key_file}"
      destination = "~/.ssh/private_key"
    }

    provisioner "remote-exec" {
      inline = [
        # Set local file permissions
        "chmod 0600 ~/.ssh/private_key",
        # Retrieve the admin key
        "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.username}@${azurerm_public_ip.chef_server.ip_address}:~/drop/admin.pem /tmp/admin.pem",
      ]
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
        "recipe[manage_a_node]"
      ],
      "snippets": {
        "virtualization": "azure-marketplace"
      },
      "chef_server": {
        "fqdn": "${azurerm_public_ip.chef_server.fqdn}",
        "org": "4thcoffee"
      },
      "nodes": {
        "rhel": {
          "node1": {
            "name": "node1",
            "identity_file": "~/.ssh/private_key",
            "ip_address": "${azurerm_public_ip.chef_server.ip_address}",
            "ssh_user": "${var.username}",
            "run_list": "recipe[learn_chef_httpd]"
          }
        }
      },
      "cloud": {
        "azure": {
          "location": "${var.azure_location}",
          "node": {
            "image_urn": "${lookup(var.chef_server_image_urn, "publisher")}:${lookup(var.chef_server_image_urn, "offer")}:${lookup(var.chef_server_image_urn, "sku")}:${lookup(var.chef_server_image_urn, "version")}",
            "size": "${var.chef_server_vm_size}"
          }
        }
      }
    }
    EOF
      destination = "/tmp/dna.json"
    }

    provisioner "remote-exec" {
      inline = [
        "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -c ${var.chef_client_channel} -v ${var.chef_client_version}",
        "sudo chef-solo -c /tmp/solo.rb -j /tmp/dna.json"
      ]
    }
}

output "ip_address" {
  value = "${azurerm_public_ip.workstation.ip_address}"
}
