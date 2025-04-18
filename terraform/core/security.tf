############ RDS SECURITY GROUP ##############
resource "aws_security_group" "rds_security_group" {
  name        = "msk-rds-security-group"
  description = "Security Group for RDS PostgreSQL"
  vpc_id      = aws_vpc.vpc-msk-cdc-example.id

  tags = {
    Name = "msk-rds-security-group"
  }
}

resource "aws_security_group_rule" "rds_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_public_internet]
  security_group_id = aws_security_group.rds_security_group.id
}
