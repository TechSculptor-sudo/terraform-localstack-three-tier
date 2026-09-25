# ---------------------------------------------------------------------------
# Networking module: VPC, 3 subnet tiers x N AZs, IGW, NAT, route tables.
#
#   public  -> route 0.0.0.0/0 via Internet Gateway (load balancer lives here)
#   app     -> route 0.0.0.0/0 via NAT Gateway      (outbound only)
#   db      -> no internet route at all             (fully isolated)
# ---------------------------------------------------------------------------

locals {
  # Turn the parallel lists into maps keyed by AZ, e.g.
  # { "us-east-1a" = "10.0.1.0/24", "us-east-1b" = "10.0.2.0/24" }.
  # for_each over a map gives each subnet a stable address like
  # aws_subnet.public["us-east-1a"] instead of aws_subnet.public[0].
  public_subnets = zipmap(var.availability_zones, var.public_subnet_cidrs)
  app_subnets    = zipmap(var.availability_zones, var.app_subnet_cidrs)
  db_subnets     = zipmap(var.availability_zones, var.db_subnet_cidrs)
}

# ---- VPC ------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# ---- Subnets --------------------------------------------------------------

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "app" {
  for_each = local.app_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "${var.name_prefix}-app-${each.key}"
    Tier = "app"
  }
}

resource "aws_subnet" "db" {
  for_each = local.db_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "${var.name_prefix}-db-${each.key}"
    Tier = "db"
  }
}

# ---- NAT gateway (single, in the first public subnet) -----------------------
# One NAT keeps cost down on real AWS (~USD 32/month + data). Production
# usually runs one NAT per AZ so losing an AZ doesn't cut outbound traffic.

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.availability_zones[0]].id

  tags = {
    Name = "${var.name_prefix}-nat"
  }

  # The NAT needs the IGW to exist before it can route anything.
  depends_on = [aws_internet_gateway.this]
}

# ---- Route tables -----------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  # Only add the default route when a NAT gateway exists.
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[0].id
    }
  }

  tags = {
    Name = "${var.name_prefix}-app-rt"
  }
}

# No routes besides the implicit "local" route: the DB tier can talk to other
# subnets inside the VPC, but has no path to or from the internet.
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-db-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}