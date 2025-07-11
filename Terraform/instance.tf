# This is the data source configuration for fetching the latest Ubuntu AMI in the us-east-1 region.
data "aws_ami" "ubuntu" {

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# This Terraform configuration deploys an AWS EC2 instance with a specified AMI, security group, IAM role, and SSH key pair.
resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.developer.key_name
  vpc_security_group_ids = [aws_security_group.this.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = var.private_key
  }

  tags = {
    Name = "Full-Stack-App-Automation-instance"
  }
}

# This configuration creates an SSH key pair for accessing the EC2 instance.
resource "aws_key_pair" "developer" {
  key_name   = var.key_name
  public_key = var.public_key
}

# This security group allows inbound SSH and HTTP traffic, and allows all outbound traffic.
resource "aws_security_group" "this" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all inbound traffic"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    },

    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all inbound traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]
}

# This IAM role allows the EC2 instance to authenticate with ECR.
resource "aws_iam_instance_profile" "this" {
  name = "ec2-instance-profile"
  role = "EC2-ECR-AUTH"
}