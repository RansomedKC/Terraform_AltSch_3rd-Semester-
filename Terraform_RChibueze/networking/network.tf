resource "aws_vpc" "kaysea_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "kaysea_igw" {
  vpc_id = aws_vpc.kaysea_vpc.id
}

resource "aws_subnet" "kaysee_public_subnet" {
  vpc_id                  = aws_vpc.kaysea_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_route_table" "kaysea_public_route_table" {
  vpc_id = aws_vpc.kaysea_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.kaysea_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kaysea_igw.id
}

resource "aws_route_table_association" "kaysee_public_subnet_rt_assoc" {
  subnet_id      = aws_subnet.kaysee_public_subnet.id
  route_table_id = aws_route_table.kaysea_public_route_table.id
}

# Create the webserver security group
resource "aws_security_group" "kaysee_webserver_sg" {
  name        = "Webserver"
  description = "Security group for frontend webserver"
  vpc_id      = aws_vpc.kaysea_vpc.id
}


  resource "aws_security_group" "kaysee_Webserver-sg" {
  name        = "Webserver"
  description = "sg for frontend webserver"
  vpc_id      = aws_vpc.kaysea_vpc.id

  ingress {
    description = "NGINX"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "react-app"
    from_port   = 0
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  