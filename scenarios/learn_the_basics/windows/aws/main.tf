variable "admin_password" {
  default = "P4ssw0rd!"
}

variable "key_name" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "az" {
  default = "b"
}

variable "instance_type" {
  default = "t2.medium"
}

# Windows Server 2012 R2 Base
variable "aws_amis" {
  default = {
    us-east-1 = "ami-bd3ba0aa"
  }
}

variable "chef_channel" {
  default = "stable"
}

variable "chef_version" {
  default = "12.12.15"
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
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

  # FTP (public port)
  ingress {
    from_port = 21
    to_port = 21
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # FTP (dynamic ports)
  ingress {
    from_port = 10000
    to_port = 10125
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

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type = "winrm"
    user = "Administrator"
    password = "${var.admin_password}"
  }

  instance_type = "${var.instance_type}"
  availability_zone = "${var.aws_region}${var.az}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  key_name = "${var.key_name}"

  # Our Security group to allow WinRM access
  security_groups = ["${aws_security_group.default.name}"]

  lifecycle {
    ignore_changes = [
      "ebs_block_device"
    ]
  }

  user_data = <<EOF
<powershell>
  winrm quickconfig -q
  winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
  winrm set winrm/config '@{MaxTimeoutms="7200000"}'
  winrm set winrm/config/service '@{AllowUnencrypted="true"}'
  winrm set winrm/config/service/auth '@{Basic="true"}'

  # turn off PowerShell execution policy restrictions
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

  Get-NetFirewallPortFilter | ?{$_.LocalPort -eq 5985 } | Get-NetFirewallRule | ?{ $_.Direction -eq "Inbound" -and $_.Profile -eq "Public" -and $_.Action -eq "Allow"} | Set-NetFirewallRule -RemoteAddress "Any"

  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.admin_password}")

  New-Item -ItemType directory -Path C:\Temp
  New-Item -ItemType directory -Path C:\vagrant
</powershell>
EOF

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
      "virtualization": "aws"
    },
    "cloud": {
      "aws": {
        "region": "${var.aws_region}",
        "node": {
          "ami_id": "${lookup(var.aws_amis, var.aws_region)}",
          "instance_type": "${var.instance_type}"
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
      "C:\\Temp\\SetupFTP.bat ${aws_instance.web.public_ip}"
    ]
  }
}

output "ip_address" {
  value = "${aws_instance.web.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.web.public_dns}"
}
