provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my-server" {
    ami = "ami-0a7d80731ae1b2435"
    instance_type = "t2.micro"
    key_name = "terraform_ec2_key"
    vpc_security_group_ids = [ aws_security_group.my-sg.id ]
    subnet_id = aws_subnet.my-public-subnet-01.id
    for_each = toset(["jenkins-master", "build-slave", "ansible"])
    tags = {
      Name = "${each.key}"
    }
  
}

resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  description = "Allow SSH inbound traffic"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description = "Allow SSH inbound traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "smy-sg"
  }
}

resource "aws_vpc" "my-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "my-vpc"
    }
  
}

resource "aws_subnet" "my-public-subnet-01" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "my-public-subnet-01"
    }
  
}

resource "aws_subnet" "my-public-subnet-02" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
      Name = "my-public-subnet-02"
    }
  
}

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "my-igw"
    }
  
}

resource "aws_route_table" "my-public-rt" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
    tags = {
      Name = "my-public-rt"
    }
  
}


resource "aws_route_table_association" "my-rta-public-subnet-01" {
    subnet_id = aws_subnet.my-public-subnet-01.id
    route_table_id = aws_route_table.my-public-rt.id
  
}

resource "aws_route_table_association" "my-rta-public-subnet-02" {
    subnet_id = aws_subnet.my-public-subnet-02.id
    route_table_id = aws_route_table.my-public-rt.id
  
}