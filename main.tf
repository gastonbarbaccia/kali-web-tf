provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key" {}
variable "aws_secret_key" {}


resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acceso SSH público (considera restringirlo por seguridad)
  }

  ingress {
    from_port   = 6080
    to_port     = 6080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acceso público al puerto 6080
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-04b4f1a9cf54c11d0" # Reemplaza con la AMI deseada
  instance_type = "t2.medium" # Cambia según necesidades
  security_groups = [aws_security_group.ec2_sg.name]

  root_block_device {
    volume_size = 30 # Tamaño del disco en GB
    volume_type = "gp2" # Tipo de volumen (puede cambiarse según necesidad)
  }

    user_data = <<-EOF
        #!/bin/bash
        exec > /var/log/user_data.log 2>&1
        set -x
        sudo apt update -y
        sudo apt upgrade -y
        sudo apt install -y docker.io git
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo docker run -d -p 6080:6080 --privileged --name kali-vnc gastonbarbaccia/kali-web-vnc
    EOF

  tags = {
    Name = "Kali-web"
  }
}

output "instance_url" {
  value = "http://${aws_instance.ec2_instance.public_ip}:6080"
  description = "URL de acceso a la aplicación en el puerto 6080"
}
