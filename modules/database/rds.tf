# ----- RDS Instance
## DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name = "${local.prefix}-${local.tags["tier"]}-subnet"

  subnet_ids = var.public_subnet_ids

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-subnet"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier = "${local.prefix}"
  engine = "mysql"
  instance_class = var.instance_type
  port = var.database_port
  allocated_storage = 20
  max_allocated_storage = 30

  db_name = var.app
  username = var.MYSQL_USER
  password = var.MYSQL_PASSWORD 

  db_subnet_group_name = aws_db_subnet_group.this.name 
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot = true

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}"
    }
  )
}

resource "aws_security_group" "db" {
  vpc_id = var.vpc_id

  name = "${local.prefix}-db-sg"

  ingress {
    from_port = var.database_port
    to_port = var.database_port
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-db-sg"
    }
  )
}
