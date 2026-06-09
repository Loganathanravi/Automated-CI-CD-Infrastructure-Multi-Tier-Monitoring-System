# 1.Terraform to connect to AWS
provider "aws" {
  region = "us-east-1"
}

# 2.AWS to open the "Front Door" (Port 22) 
resource "aws_security_group" "my_sg" {
  name = "allow_ssh_jenkins_v2"

  # Rule for SSH (Port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule for Jenkins (Port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Prometheus Port
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana Port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Rule for outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# 3.AWS to create the computer (The Server)
resource "aws_instance" "my_server" {
  ami = "ami-04a81a99f5ec58529" # Official Ubuntu 24.04 LTS for us-east-1
  instance_type = "t3.micro"             # This is the free size
  key_name      = "my-devops-key"      # The name of the key made in AWS
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "My-First-Server"
  }
}

# 4.Terraform to show the computer's address (IP)
output "computer_address" {
  value = aws_instance.my_server.public_ip
}