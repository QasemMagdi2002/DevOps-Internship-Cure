resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rds-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow PostgreSQL only from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username

  # Requires modern AWS provider write-only support.
  # If your provider errors, use password = var.db_master_password as fallback,
  # but that fallback stores a sensitive value in state.
  password_wo         = var.db_master_password
  password_wo_version = 1

  allocated_storage     = var.allocated_storage
  max_allocated_storage = max(var.allocated_storage * 2, 40)
  storage_type          = "gp3"
  storage_encrypted     = true

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:03:00-sun:04:00"

  deletion_protection       = var.protect_data_resources
  skip_final_snapshot       = var.protect_data_resources ? false : true
  final_snapshot_identifier = var.protect_data_resources ? "${var.name_prefix}-postgres-final" : null

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-postgres"
  })

  lifecycle {
    precondition {
      condition     = var.allocated_storage >= 20
      error_message = "RDS allocated storage must be at least 20 GB."
    }

    postcondition {
      condition     = self.publicly_accessible == false
      error_message = "RDS must not be publicly accessible."
    }

    postcondition {
      condition     = self.storage_encrypted == true
      error_message = "RDS storage must be encrypted."
    }
  }
}
