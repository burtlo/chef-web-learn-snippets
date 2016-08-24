variable "project" {}
variable "service_account_file" {}
variable "username" {}
variable "ssh_key_file" {}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "b"
}

variable "chef_channel" {
  default = "stable"
}

variable "chef_version" {
  default = "12.12.15"
}

variable "image" {
  default = "windows-server-2012-r2-dc-v20160809"
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "hostname" {
  default = "windows-compute"
}

variable "username" {
  default = "chef"
}

variable "password" {
  default = "P4ssw0rd1234!"
}

data "template_file" "bootstrap" {
  template = "${file("../../../shared/scripts/bootstrap.ps1.tpl")}"

  vars {
      username = "${var.username}"
      password = "${var.password}"
  }
}

# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("${var.service_account_file}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

# until gcloud compute instances describe windows-compute; do sleep 1; done; gcloud compute reset-windows-password windows-compute --quiet | grep password: | sed 's/password\:\s*\(\S*\)/\1/' | sed -e 's/^[[:space:]]*//' > secrets/password.txt

resource "google_compute_instance" "default" {
  name         = "${var.hostname}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region}-${var.zone}"
  tags         = ["www-node"]

  disk {
    image = "${var.image}"
  }

  // Local SSD disk
  disk {
    type    = "local-ssd"
    scratch = true
  }

  #network_interface {
  #  network = "default"
  #  access_config {
  #    // Ephemeral IP
  #  }
  #}

  network_interface {
    network = "default" # "${google_compute_network.network.name}"
    access_config {
      nat_ip = "${google_compute_address.www.address}"
    }
  }

  metadata {
    gce-initial-windows-user = "${var.username}"
    #gce-initial-windows-password = "${var.password}"
    sysprep-specialize-script-ps1 = "${data.template_file.bootstrap.rendered}"
  }
}

resource "null_resource" "reset_windows_password" {
  depends_on = ["google_compute_instance.default"]

  provisioner "local-exec" {
    command = "gcloud compute reset-windows-password \"${var.hostname}\" --quiet | grep password: | sed 's/password\\:\\s*\\(\\S*\\)/\\1/' | sed -e 's/^[[:space:]]*//' > secrets/password.txt"
  }
}

resource "null_resource" "run_provisioners" {
    depends_on = ["null_resource.reset_windows_password"]

    # This lousy POS just won't connect.
    #  null_resource.run_provisioners: Still creating... (4m50s elapsed)
    #  Error applying plan:
    #
    #  1 error(s) occurred:
    #  http error: 401 -

    connection {
      type     = "winrm"
      host     = "${google_compute_instance.default.network_interface.0.access_config.0.assigned_nat_ip}"
      insecure = true
      #https    = false
      user     = "${var.username}"
      password = "${file("secrets/password.txt")}"
    }

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
        "virtualization": "compute"
      },
      "cloud": {
        "compute": {
          "zone": "${var.region}-${var.zone}",
          "node": {
            "image": "${var.image}",
            "machine_type": "${var.machine_type}"
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
        "C:\\Temp\\SetupFTP.bat ${google_compute_instance.default.network_interface.0.access_config.0.assigned_nat_ip}"
      ]
    }
}

resource "google_compute_address" "www" {
    name = "tf-www-address"
}

resource "google_compute_firewall" "www" {
  name = "tf-www-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["21", "80", "443", "3389", "5985"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["www-node"]
}

output "ip_address" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "admin_username" {
  value = "${var.username}"
}
