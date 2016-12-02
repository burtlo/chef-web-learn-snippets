variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}
variable "ssh_key_file" {}

###
### TODO: Manually create an OpsWorks stack and update these values.
### TODO: Also remember to copy starter_kit.zip to the secrets directory.
###
variable "chef_automate" {
  type = "map"
  default = {
    fqdn = "test-xcdbs22xaaf3cmpz.gamma.opsworks-cm.io"
    version = "12.11.1"
    instance_type = "t2.medium"
  }
}
###
###

variable "chef_client_channel" {
  default = "stable"
}

variable "chef_client_version" {
  default = "12.12.15"
}

variable "chef_server_channel" {
  default = "stable"
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

variable "node1-centos" {
  type = "map"
  default = {
    ami = "ami-6d1c2007" # CentOS 7
    instance_type = "t2.micro"
    name_tag = "node1-centos"
  }
}

variable "windows_password" {
  default = "7pXySo%!Cz"
}

variable "node1-windows" {
  type = "map"
  default = {
    ami = "ami-3f0c4628" # Windows Server 2012 R2
    instance_type = "t2.medium"
    name_tag = "node1-windows"
  }
}

variable "node1-ubuntu" {
  type = "map"
  default = {
    ami = "ami-2d39803a" # Ubuntu 14.04
    instance_type = "t2.micro"
    name_tag = "node1-ubuntu"
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

resource "aws_security_group" "linux_sg" {
  name = "linux_sg"
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

# node1-centos
resource "aws_instance" "node1-centos" {
  ami = "${lookup(var.node1-centos, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.node1-centos, "instance_type")}"
  security_groups = ["${aws_security_group.linux_sg.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.node1-centos, "name_tag")}"
  }
  key_name = "${var.key_name}"
}

# node1-ubuntu
resource "aws_instance" "node1-ubuntu" {
  ami = "${lookup(var.node1-ubuntu, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
  instance_type = "${lookup(var.node1-ubuntu, "instance_type")}"
  security_groups = ["${aws_security_group.linux_sg.name}"]
  associate_public_ip_address = true
  tags {
    Name = "${lookup(var.node1-ubuntu, "name_tag")}"
  }
  key_name = "${var.key_name}"
}

# Windows node
resource "aws_instance" "node1-windows" {
  ami = "${lookup(var.node1-windows, "ami")}"
  availability_zone = "${var.region}${var.availability_zone}"
   instance_type = "${lookup(var.node1-windows, "instance_type")}"
   security_groups = ["${aws_security_group.windows_webserver.name}"]
   associate_public_ip_address = true
   tags {
     Name = "${lookup(var.node1-windows, "name_tag")}"
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
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

Get-NetFirewallPortFilter | ?{$_.LocalPort -eq 5985 } | Get-NetFirewallRule | ?{ $_.Direction -eq "Inbound" -and $_.Profile -eq "Public" -and $_.Action -eq "Allow"} | Set-NetFirewallRule -RemoteAddress "Any"

$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${var.windows_password}")

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
      "mkdir -p ~/Downloads",
      "chmod 0600 ~/.ssh/private_key" # Set local file permissions
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
    source = "secrets/starter_kit.zip"
    destination = "~/Downloads/starter_kit.zip"
  }

  provisioner "file" {
      content = <<EOF
  {
    "run_list": [
      "recipe[manage_a_node]"
    ],
    "snippets": {
      "virtualization": "opsworks"
    },
    "chef_server": {
      "fqdn": "${lookup(var.chef_automate, "fqdn")}",
      "org": "default"
    },
    "chef_automate": {
      "fqdn": "${lookup(var.chef_automate, "fqdn")}"
    },
    "nodes": [
      {
        "name": "node1-centos",
        "platform": "rhel",
        "ssh_user": "centos",
        "identity_file": "~/.ssh/private_key",
        "ip_address": "${aws_instance.node1-centos.public_ip}",
        "cookbook": "learn_chef_httpd"
      },
      {
        "name": "node1-ubuntu",
        "platform": "ubuntu",
        "ssh_user": "ubuntu",
        "identity_file": "~/.ssh/private_key",
        "ip_address": "${aws_instance.node1-ubuntu.public_ip}",
        "cookbook": "learn_chef_apache2"
      },
      {
        "name": "node1-windows",
        "platform": "windows",
        "winrm_user": "Administrator",
        "password": "${var.windows_password}",
        "ip_address": "${aws_instance.node1-windows.public_ip}",
        "cookbook": "learn_chef_iis"
      }
    ],
    "products": {
      "versions": {
        "automate": {
          "amazon-linux": "${lookup(var.chef_automate, "version")}"
        }
      }
    },
    "cloud": {
      "aws": {
        "region": "${var.region}",
        "automate": {
          "instance_type": "${lookup(var.chef_automate, "instance_type")}"
        },
        "workstation": {
          "ami_id": "${lookup(var.workstation, "ami")}",
          "instance_type": "${lookup(var.workstation, "instance_type")}"
        },
        "nodes": {
          "rhel": {
            "ami_id": "${lookup(var.node1-centos, "ami")}",
            "instance_type": "${lookup(var.node1-centos, "instance_type")}"
          },
          "ubuntu": {
            "ami_id": "${lookup(var.node1-ubuntu, "ami")}",
            "instance_type": "${lookup(var.node1-ubuntu, "instance_type")}"
          },
          "windows": {
            "ami_id": "${lookup(var.node1-windows, "ami")}",
            "instance_type": "${lookup(var.node1-windows, "instance_type")}"
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

output "admin_username" {
  value = "ubuntu"
}
