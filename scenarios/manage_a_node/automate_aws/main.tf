variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}
variable "ssh_key_file" {}

variable "chef_client_channel" {
  default = "stable"
}

variable "chef_client_version" {
  default = "12.12.15"
}

variable "chef_server_channel" {
  default = "stable"
}

variable "chef_server_version" {
  default = "12.8.0"
}

variable push_jobs_channel {
  default = "stable"
}

variable push_jobs_version {
  default = "1.1.6"
}

variable delivery_channel {
  default = "stable"
}

variable delivery_version {
  default = "0.5.204"
}

# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-east-1"
}

variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "b"
}

variable "chef_automate" {
  type = "map"
  default = {
    ami = "ami-2d39803a" # Ubuntu 14.04
    instance_type = "t2.large"
    name_tag = "chef-automate"
  }
}

variable "chef_server" {
  type = "map"
  default = {
    ami = "ami-2d39803a" # Ubuntu 14.04
    instance_type = "t2.large"
    name_tag = "chef-server"
  }
}

variable "node1" {
  type = "map"
  default = {
    ami = "ami-6d1c2007" # CentOS 7
    instance_type = "t2.micro"
    name_tag = "node1-centos"
  }
}

variable "workstation" {
  type = "map"
  default = {
    ami = "ami-2d39803a" # Ubuntu 14.04
    instance_type = "t2.micro"
    name_tag = "workstation"
  }
}

resource "aws_security_group" "chef_server" {
  name = "chef_server"
  description = "Rules for Chef server"

  # Push Jobs
  ingress {
      from_port = 10000
      to_port = 10003
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "chef_automate" {
  name = "chef_automate"
  description = "Rules for Chef Automate"

  # Delivery Git (SCM)
  ingress {
      from_port = 8989
      to_port = 8989
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "node1" {
  name = "node1"
  description = "Rules for a basic Linux web server"

  # SSH
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "workstation" {
  name = "workstation"
  description = "Rules for a Linux workstation"

  # SSH
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Template for initial configuration bash script
data "template_file" "install-chef-server" {
    template = "${file("../../shared/scripts/install-chef-server.tpl")}"
    vars {
      server_channel = "${var.chef_server_channel}"
      server_version = "${var.chef_server_version}"
      server_fqdn = "${aws_instance.chef_automate.public_dns}"
      push_jobs_channel = "${var.push_jobs_channel}"
      push_jobs_version = "${var.push_jobs_version}"
    }
}

# Template for initial configuration bash script
data "template_file" "install-chef-automate" {
    template = "${file("../../shared/scripts/install-chef-automate.tpl")}"
    vars {
      delivery_channel = "${var.delivery_channel}"
      delivery_version = "${var.delivery_version}"
      chef_server_fqdn = "${aws_instance.chef_server.public_dns}"
      chef_automate_fqdn = "${aws_instance.chef_automate.public_dns}"
      chef_automate_org = "4thcoffee"
    }
}

# Template for initial configuration bash script
data "template_file" "data_collector" {
    template = "${file("../../shared/scripts/data_collector.rb.tpl")}"
    vars {
      chef_automate_fqdn = "${aws_instance.chef_automate.public_dns}"
    }
}

# Chef server
resource "aws_instance" "chef_server" {
  ami = "${lookup(var.chef_server, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.chef_server, "instance_type")}"
  security_groups = ["${aws_security_group.chef_server.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.chef_server, "name_tag")}"
  }
  key_name = "${var.key_name}"
}

# Chef Automate
resource "aws_instance" "chef_automate" {
  ami = "${lookup(var.chef_automate, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.chef_automate, "instance_type")}"
  security_groups = ["${aws_security_group.chef_automate.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.chef_automate, "name_tag")}"
  }
  key_name = "${var.key_name}"
}

# node
resource "aws_instance" "node1" {
  ami = "${lookup(var.node1, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.node1, "instance_type")}"
  security_groups = ["${aws_security_group.node1.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.node1, "name_tag")}"
  }
  key_name = "${var.key_name}"

  connection {
    host     = "${aws_instance.node1.public_ip}"
    user     = "centos"
    key_file = "${var.ssh_key_file}"
  }

  provisioner "file" {
    content = "${data.template_file.data_collector.rendered}"
    destination = "/tmp/data_collector.rb"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/chef/trusted_certs",
      "sudo chmod 0777 /etc/chef/trusted_certs",
      "sudo mkdir -p /etc/chef/client.d",
      "sudo cp /tmp/data_collector.rb /etc/chef/client.d/data_collector.rb"
    ]
  }
}

# workstation
resource "aws_instance" "workstation" {
  ami = "${lookup(var.workstation, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.workstation, "instance_type")}"
  security_groups = ["${aws_security_group.workstation.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.workstation, "name_tag")}"
  }
  key_name = "${var.key_name}"

  #user_data = "${file("../../shared/scripts/install-chef-server.txt")}"

  connection {
    host     = "${aws_instance.workstation.public_ip}"
    user     = "ubuntu"
    key_file = "${var.ssh_key_file}"
  }

  provisioner "file" {
    content = "${data.template_file.install-chef-server.rendered}"
    destination = "/tmp/install-chef-server.sh"
  }

  provisioner "file" {
    content = "${data.template_file.install-chef-automate.rendered}"
    destination = "/tmp/install-chef-automate.sh"
  }

  provisioner "file" {
    source = "secrets/automate.license"
    destination = "/tmp/automate.license"
  }

  provisioner "file" {
    source = "${var.ssh_key_file}"
    destination = "~/.ssh/private_key"
  }

  provisioner "remote-exec" {
    inline = [
      # Set local file permissions
      "chmod 0600 ~/.ssh/private_key",
      "chmod +x /tmp/install-chef-server.sh",
      "chmod +x /tmp/install-chef-automate.sh",
      # Copy files to Chef server
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/install-chef-server.sh ubuntu@${aws_instance.chef_server.public_ip}:/tmp/install-chef-server.sh",
      # Install Chef server
      "ssh -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.chef_server.public_ip} '/tmp/install-chef-server.sh'",
      # Retrieve the admin key
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.chef_server.public_ip}:~/drop/delivery.pem /tmp/delivery.pem",
      # Copy files to Chef Automate
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/install-chef-automate.sh ubuntu@${aws_instance.chef_automate.public_ip}:/tmp/install-chef-automate.sh",
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/automate.license ubuntu@${aws_instance.chef_automate.public_ip}:/tmp/automate.license",
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/delivery.pem ubuntu@${aws_instance.chef_automate.public_ip}:/tmp/delivery.pem",
      # Install Chef Automate
      "ssh -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.chef_automate.public_ip} '/tmp/install-chef-automate.sh'",
      # Copy cert from Chef Automate to node
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.chef_automate.public_ip}:/var/opt/delivery/nginx/ca/${aws_instance.chef_automate.public_dns}.crt /tmp/${aws_instance.chef_automate.public_dns}.crt",
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/${aws_instance.chef_automate.public_dns}.crt centos@${aws_instance.node1.public_ip}:/etc/chef/trusted_certs",
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
      "virtualization": "aws"
    },
    "chef_server": {
      "fqdn": "${aws_instance.chef_server.public_dns}",
      "org": "4thcoffee"
    },
    "chef_automate": {
      "fqdn": "${aws_instance.chef_automate.public_dns}"
    },
    "nodes": {
      "rhel": {
        "node1": {
          "name": "node1",
          "identity_file": "~/.ssh/private_key",
          "ip_address": "${aws_instance.node1.public_ip}",
          "ssh_user": "centos",
          "run_list": "recipe[learn_chef_httpd]"
        }
      }
    },
    "cloud": {
      "aws": {
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
  value = "${aws_instance.workstation.public_ip}"
}

output "chef_server_ip_address" {
  value = "${aws_instance.chef_server.public_ip}"
}

output "admin_username" {
  value = "ubuntu"
}
