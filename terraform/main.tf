data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_security_group" "weather_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Weather Dashboard"

  ingress {
    description = "Weather Dashboard"
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

resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "weather_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  vpc_security_group_ids = [
    aws_security_group.weather_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash

              apt-get update -y
              apt-get install -y docker.io

              systemctl enable docker
              systemctl start docker

              docker pull ghcr.io/sasi-76/docker-weather:latest

              docker run -d \
                --name pro-weather \
                --restart unless-stopped \
                -p 80:5000 \
                -e OPENWEATHER_API_KEY="${var.openweather_api_key}" \
                ghcr.io/sasi-76/docker-weather:latest
              EOF

  tags = {
    Name = var.project_name
  }
}