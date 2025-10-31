resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name                                        = var.vpc_name
      "kubernetes.io/cluster/${var.vpc_name}-eks" = "shared"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    { Name = "${var.vpc_name}-igw" }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name                                        = "${var.vpc_name}-public-subnet-${count.index + 1}"
      "kubernetes.io/cluster/${var.vpc_name}-eks" = "shared"
      "kubernetes.io/role/elb"                    = "1"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.common_tags,
    {
      Name                                        = "${var.vpc_name}-private-subnet-${count.index + 1}"
      "kubernetes.io/cluster/${var.vpc_name}-eks" = "owned"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

# NAT Gateway and EIP resources commented out to save costs
# Uncomment if you need private subnets with internet access

# resource "aws_eip" "nat" {
#   count = length(var.public_subnet_cidrs)

#   domain = "vpc"

#   tags = merge(
#     var.common_tags,
#     { Name = "${var.vpc_name}-nat-eip-${count.index + 1}" }
#   )

#   depends_on = [aws_internet_gateway.this]
# }

# resource "aws_nat_gateway" "this" {
#   count = length(var.public_subnet_cidrs)

#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id

#   tags = merge(
#     var.common_tags,
#     { Name = "${var.vpc_name}-nat-gw-${count.index + 1}" }
#   )

#   depends_on = [aws_internet_gateway.this]
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.vpc_name}-public-rt" }
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route tables commented out since we're using public subnets only
# Uncomment if you need private subnets with NAT gateway routing

# resource "aws_route_table" "private" {
#   count = length(var.private_subnet_cidrs)

#   vpc_id = aws_vpc.this.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.this[count.index].id
#   }

#   tags = merge(
#     var.common_tags,
#     { Name = "${var.vpc_name}-private-rt-${count.index + 1}" }
#   )
# }

# resource "aws_route_table_association" "private" {
#   count = length(var.private_subnet_cidrs)

#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private[count.index].id
# }
