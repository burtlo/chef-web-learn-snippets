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

variable "windows_password" {
  default = "7pXySo%!Cz"
}

variable "chef_server" {
  type = "map"
  default = {
    ami = "ami-cc5a23db" # 12.8.0-2
    instance_type = "t2.large"
    name_tag = "chef-server-marketplace"
  }
}

variable "node1_centos" {
  type = "map"
  default = {
    ami = "ami-6d1c2007" # CentOS 7
    instance_type = "t2.micro"
    name_tag = "node1-centos"
  }
}

variable "node1_ubuntu" {
  type = "map"
  default = {
    ami = "ami-2d39803a" # Ubuntu 14.04
    instance_type = "t2.micro"
    name_tag = "node1-ubuntu"
  }
}

variable "node1_windows" {
  type = "map"
  default = {
    ami = "ami-bfeddca8" # Windows Server 2012 R2
    instance_type = "t2.medium"
    name_tag = "node1-windows"
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

  # SSH
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # ?
  ingress {
      from_port = 8443
      to_port = 8443
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

resource "aws_security_group" "linux_webserver" {
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

resource "aws_security_group" "windows_webserver" {
  name = "Learn Chef - web server - Windows"

  # WinRM
  ingress {
    from_port = 5985
    to_port = 5985
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

  # RDP
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
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

  connection {
    host     = "${aws_instance.chef_server.public_ip}"
    user     = "ec2-user"
    key_file = "${var.ssh_key_file}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir ~/drop",
      "until sudo chef-server-ctl user-create admin Bob Admin admin@4thcoffee.com insecurepassword --filename ~/drop/admin.pem; do sleep 1m; done",
      "sudo chef-server-ctl org-create 4thcoffee \"Fourth Coffee, Inc.\" --association_user admin --filename 4thcoffee-validator.pem",
    ]
  }
}

# CentOS node
resource "aws_instance" "node1_centos" {
  ami = "${lookup(var.node1_centos, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.node1_centos, "instance_type")}"
  security_groups = ["${aws_security_group.linux_webserver.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.node1_centos, "name_tag")}"
  }
  key_name = "${var.key_name}"
}

# Ubuntu node
resource "aws_instance" "node1_ubuntu" {
  ami = "${lookup(var.node1_ubuntu, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.node1_ubuntu, "instance_type")}"
  security_groups = ["${aws_security_group.linux_webserver.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.node1_ubuntu, "name_tag")}"
  }
  key_name = "${var.key_name}"
}

# Windows node
resource "aws_instance" "node1_windows" {
  ami = "${lookup(var.node1_windows, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.node1_windows, "instance_type")}"
  security_groups = ["${aws_security_group.windows_webserver.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.node1_windows, "name_tag")}"
  }
  key_name = "${var.key_name}"
  lifecycle {
    ignore_changes = [
      "ebs_block_device"
    ]
  }

  user_data = <<EOF
<powershell>
  # turn off PowerShell execution policy restrictions
  # Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

  Get-NetFirewallPortFilter | ?{$_.LocalPort -eq 5985 } | Get-NetFirewallRule | ?{ $_.Direction -eq "Inbound" -and $_.Profile -eq "Public" -and $_.Action -eq "Allow"} | Set-NetFirewallRule -RemoteAddress "Any"

  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.windows_password}")

  New-Item -ItemType directory -Path C:\Temp
</powershell>
EOF
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

  connection {
    host     = "${aws_instance.workstation.public_ip}"
    user     = "ubuntu"
    key_file = "${var.ssh_key_file}"
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
      "scp -i ~/.ssh/private_key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${aws_instance.chef_server.public_ip}:~/drop/admin.pem /tmp/admin.pem",
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
      "virtualization": "aws-marketplace"
    },
    "chef_server": {
      "fqdn": "${aws_instance.chef_server.public_dns}",
      "org": "4thcoffee"
    },
    "nodes": [
      {
        "name": "node1-centos",
        "platform": "rhel",
        "ssh_user": "centos",
        "identity_file": "~/.ssh/private_key",
        "ip_address": "${aws_instance.node1_centos.public_ip}",
        "cookbook": "learn_chef_httpd"
      },
      {
        "name": "node1-ubuntu",
        "platform": "ubuntu",
        "ssh_user": "ubuntu",
        "identity_file": "~/.ssh/private_key",
        "ip_address": "${aws_instance.node1_ubuntu.public_ip}",
        "cookbook": "learn_chef_apache2"
      },
      {
        "name": "node1-windows",
        "platform": "windows",
        "winrm_user": "Administrator",
        "password": "${var.windows_password}",
        "ip_address": "${aws_instance.node1_windows.public_ip}",
        "cookbook": "learn_chef_iis"
      }
    ],
    "cloud": {
      "aws": {
        "region": "${var.region}",
        "chef_server": {
          "ami_id": "${lookup(var.chef_server, "ami")}",
          "instance_type": "${lookup(var.chef_server, "instance_type")}"
        },
        "workstation": {
          "ami_id": "${lookup(var.workstation, "ami")}",
          "instance_type": "${lookup(var.workstation, "instance_type")}"
        },
        "nodes": {
          "rhel": {
            "ami_id": "${lookup(var.node1_centos, "ami")}",
            "instance_type": "${lookup(var.node1_centos, "instance_type")}"
          },
          "ubuntu": {
            "ami_id": "${lookup(var.node1_ubuntu, "ami")}",
            "instance_type": "${lookup(var.node1_ubuntu, "instance_type")}"
          },
          "windows": {
            "ami_id": "${lookup(var.node1_windows, "ami")}",
            "instance_type": "${lookup(var.node1_windows, "instance_type")}"
          }
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
  value = "${aws_instance.workstation.public_ip}"
}

output "chef_server_ip_address" {
  value = "${aws_instance.chef_server.public_ip}"
}

output "admin_username" {
  value = "ubuntu"
}
