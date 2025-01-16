resource "aws_instance" "ec2_instance" {
  ami = "ami-063d43db0594b521b" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id = aws_subnet.vpc_public_subnet.id
  key_name = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.public_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo systemctl enable docker
  EOF

#    sudo docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
#    sudo docker pull $DOCKER_USERNAME/$DOCKER_REPO:$DOCKER_TAG
#    sudo docker run -d -p 80:3000 $DOCKER_USERNAME/$DOCKER_REPO:$DOCKER_TAG

  tags = {
    Name = "DockerEC2"
  }
}


# Security group that allows inbound and outbound traffic
resource "aws_security_group" "public_sg" {
  name = "public_sg"
  description = "Allow inbound and outbound traffic"
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "PublicSecurityGroup"
  }

  # inbound traffic (allow all http, tcp helps secure connection)
  # For HTTPS (443) needs certificate (AWS Certificate Manager)
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound traffic (allow all ssh, tcp helps secure connection)
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # limit in production
  }

  # outbound traffic (allow all)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_eip" "ec2_eip" {
  instance = aws_instance.ec2_instance.id

  tags = {
    Name = "DockerEC2EIP"
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "./my_key_pair.pem"
}