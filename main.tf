provider "aws" {
  region = "us-east-1"
}

# 1. VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "jenkins-vpc"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "jenkins-igw"
  }
}

# 3. Subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-public-subnet"
  }
}

# 4. Route Table & Association
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "jenkins-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. AMI (RedHat 9)
data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat Owner ID

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# 6. Key Pair (ضفنا المفتاح عشان نستخدمه في SSH و Ansible)
resource "aws_key_pair" "deployer" {
  key_name   = "jenkins-agent-key"
  public_key = file("~/.ssh/jenkins_agent_key.pub") # استخدم نفس الـ Public Key بتاعك
}

# 7. Security Group
resource "aws_security_group" "my_jenkins_sg" {
  name        = "my-jenkins-security-group"
  description = "Access to ports 22, 443, and 8080 for Jenkins"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Incoming SSH"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Incoming HTTP App"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My-Jenkins-Security-Group"
  }
}

# 8. EC2 Instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.rhel.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.my_jenkins_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = {
    Name = "redhat-jenkins-agent"
  }
}

# Output الـ IP عشان نعرف نستخدمه في Ansible على طول
output "ec2_public_ip" {
  value       = aws_instance.app.public_ip
  description = "Public IP of the EC2 Instance"
}