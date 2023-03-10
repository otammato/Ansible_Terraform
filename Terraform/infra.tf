provider "aws" {
  region                    = "us-east-1"
  shared_config_files       = ["/home/ec2-user/.aws/config"]
  shared_credentials_files  = ["/home/ec2-user/.aws/credentials"]
}


data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ssm_parameter" "current-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


resource "aws_default_vpc" "default" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_default_vpc.default.id
  # cidr_block = "10.0.1.0/24"
  cidr_block = "172.31.98.128/25"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "ansible-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_default_vpc.default.id
  # cidr_block = "10.0.2.0/24"
  cidr_block = "172.31.99.128/25"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name     = "ansible-private-subnet"
  }
}


resource "aws_security_group" "ec2_master_security_group" {
  name        = "ec2-master-security-group"
  description = "Allow ssh access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change this to your ip for the security reasons
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-slave-security-group"
  description = "Allow ssh and http access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change this to your ip for the security reasons
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "master_instance" {
  ami           = data.aws_ssm_parameter.current-ami.value
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_master_security_group.id]
  associate_public_ip_address = true
  key_name      = "test_delete"
  
  user_data     = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras install ansible2 -y
  EOF
  
  tags = {
    Name = "master_instance"
  }
}

resource "aws_instance" "ansible_slave" {
  count = 3
  ami           = data.aws_ssm_parameter.current-ami.value
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  associate_public_ip_address = true
  key_name      = "test_delete"

  tags = {
    Name = "slave_instance${count.index + 1}"
  }
}

resource "local_file" "slaves_ips" {
    content = format("%s\n%s\n%s",
  aws_instance.ansible_slave.*.private_ip[0],
  aws_instance.ansible_slave.*.private_ip[1],
  aws_instance.ansible_slave.*.private_ip[2]
)

  filename = "inventory"
}


output "master_instance_public_ip" {
  value = aws_instance.master_instance.public_ip
}

output "slaves_ips" {
  value = ["${aws_instance.ansible_slave.*.private_ip}"]
}



