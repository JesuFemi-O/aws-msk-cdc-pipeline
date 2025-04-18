resource "aws_vpc" "vpc-msk-cdc-example" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "VPC: vpc-msk-cdc-example"
  }
}

resource "aws_subnet" "msk_cdc_public_subnet" {
  vpc_id     = aws_vpc.vpc-msk-cdc-example.id
  cidr_block = var.cidr_public_subnet
  availability_zone = var.public_subnet_availability_zone

  tags = {
    Name = "Subnet-Public : msk_cdc_public_subnet"
  }
}

resource "aws_subnet" "msk_cdc_private_subnets" {
  for_each = tomap({
    "private-subnet-1" = { cidr = var.cidr_private_subnet[0], az = var.us_availability_zone[0] }
    "private-subnet-2" = { cidr = var.cidr_private_subnet[1], az = var.us_availability_zone[0] }
    "private-subnet-3" = { cidr = var.cidr_private_subnet[2], az = var.us_availability_zone[1] }
    "private-subnet-4" = { cidr = var.cidr_private_subnet[3], az = var.us_availability_zone[1] }
    "private-subnet-5" = { cidr = var.cidr_private_subnet[4], az = var.us_availability_zone[2] }
  })

  vpc_id            = aws_vpc.vpc-msk-cdc-example.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "Subnet-Private : ${each.key}"
  }
}

resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.vpc-msk-cdc-example.id
  tags = {
    Name = "IGW: For VPC DataEng CDC POC"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.msk_cdc_public_subnet.id
  tags = {
    "Name" = "Private NAT GW: For VPC DataEng CDC POC "
  }
}

resource "aws_route_table" "dataeng_msk_cdc_poc_public_route_table" {
  vpc_id = aws_vpc.vpc-msk-cdc-example.id
  route {
    cidr_block = var.cidr_public_internet
    gateway_id = aws_internet_gateway.public_internet_gateway.id
  }
  tags = {
    Name = "RT Public: For VPC DataEng CDC POC "
  }
}

resource "aws_route_table" "dataeng_msk_cdc_poc_private_route_table" {
  vpc_id = aws_vpc.vpc-msk-cdc-example.id
  depends_on = [aws_nat_gateway.nat_gateway]
  route {
    cidr_block =var.cidr_public_internet
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "RT Private: For VPC DataEng CDC POC "
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  depends_on = [aws_subnet.msk_cdc_public_subnet, aws_route_table.dataeng_msk_cdc_poc_public_route_table]
  subnet_id      = aws_subnet.msk_cdc_public_subnet.id
  route_table_id = aws_route_table.dataeng_msk_cdc_poc_public_route_table.id
}

resource "aws_route_table_association" "private_subnet_asso" {
  for_each = aws_subnet.msk_cdc_private_subnets
  depends_on = [aws_subnet.msk_cdc_private_subnets, aws_route_table.dataeng_msk_cdc_poc_private_route_table]
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dataeng_msk_cdc_poc_private_route_table.id
}

