# Create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(var.public_subnet_cidrs, each.value))
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-${each.key}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(var.private_subnet_cidrs, each.value))
  tags = {
    Name = "${var.vpc_name}-private-${each.key}"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "this" {
  count        = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id # Attach to the first public subnet
  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0
  vpc   = true
  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }
  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count = var.enable_nat_gateway && var.single_nat_gateway ? length(aws_subnet.private) : 0
  subnet_id      = values(aws_subnet.private)[count.index].id
  route_table_id = aws_route_table.private[0].id
}

