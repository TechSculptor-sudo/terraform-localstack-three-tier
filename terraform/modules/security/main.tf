# ---------------------------------------------------------------------------
# Security module: one security group per tier, chained by SG references.
#
#   clients --HTTP 80--> [lb-sg] --app port--> [app-sg] --5432--> [db-sg]
#
# Least privilege: every rule names the exact port AND the exact source or
# destination. Tiers trust the security group in front of them, not an IP
# range, so rules keep working when instances are replaced or scaled.
# Nothing allows traffic from the internet to the app or database tiers.
# ---------------------------------------------------------------------------

# ---- Security groups (no inline rules; rules are separate resources below) --
# Terraform removes AWS's default "allow all outbound" rule when it creates a
# security group, so each group starts as deny-all in both directions.

resource "aws_security_group" "lb" {
  name        = "${var.name_prefix}-lb-sg"
  description = "Load balancer: HTTP from clients, forwards to the app tier"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-lb-sg"
    Tier = "public"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Application: traffic only from the load balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-app-sg"
    Tier = "app"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Database: PostgreSQL only from the app tier"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-db-sg"
    Tier = "db"
  }
}

# ---- Load balancer rules ------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "lb_http" {
  for_each = toset(var.load_balancer_allowed_cidrs)

  security_group_id = aws_security_group.lb.id
  description       = "HTTP from clients"
  ip_protocol       = "tcp"
  from_port         = var.load_balancer_port
  to_port           = var.load_balancer_port
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "lb_to_app" {
  security_group_id            = aws_security_group.lb.id
  description                  = "Forward requests to the app tier only"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = aws_security_group.app.id
}

# ---- Application rules ----------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "app_from_lb" {
  security_group_id            = aws_security_group.app.id
  description                  = "App port from the load balancer only"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = aws_security_group.lb.id
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  description                  = "PostgreSQL to the database tier only"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = aws_security_group.db.id
}

# Outbound HTTPS (through the NAT gateway) for OS/package updates and AWS APIs.
# This is outbound only -- nothing on the internet can open a connection in.
resource "aws_vpc_security_group_egress_rule" "app_https_out" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS out via NAT for updates and AWS APIs"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# ---- Database rules -------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from the app tier only"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = aws_security_group.app.id
}

# No egress rules for the database: it never starts connections of its own.
# Security groups are stateful, so replies to the app's queries still get out.
