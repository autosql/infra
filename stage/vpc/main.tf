locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = terraform.workspace
  }
  prefix = "${var.app}-${terraform.workspace}"
}



resource "aws_vpc" "this" {
  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-vpc"
    }
  )

  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  count = length(var.az)

  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.az[count.index]

  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-public-subnet${count.index}"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-igw"
    }
  )
}

# ----- route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-route-table"
    }
  )
}

resource "aws_route_table_association" "public-rt-assoc" {
  count = length(var.az)
  route_table_id = aws_route_table.public.id
  subnet_id = element(aws_subnet.public.*.id, count.index)
}
