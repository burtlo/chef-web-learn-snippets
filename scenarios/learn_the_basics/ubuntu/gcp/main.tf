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
  default = "ubuntu-1404-trusty-v20160809a"
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "hostname" {
  default = "ubuntu-compute"
}

# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("${var.service_account_file}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

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

  network_interface {
    network = "default" # "${google_compute_network.network.name}"
    access_config {
      nat_ip = "${google_compute_address.www.address}"
    }
  }

  connection {
    user     = "${var.username}"
    key_file = "${var.ssh_key_file}"
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
      "virtualization": "gcp",
      "prompt_character": "chef@${var.hostname}:~$"
    },
    "cloud": {
      "gcp": {
        "zone": "${var.region}-${var.zone}",
        "node": {
          "image": "${var.image}",
          "machine_type": "${var.machine_type}"
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

resource "google_compute_address" "www" {
    name = "tf-www-address"
}

resource "google_compute_firewall" "www" {
  name = "tf-www-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22", "80", "443"]
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
