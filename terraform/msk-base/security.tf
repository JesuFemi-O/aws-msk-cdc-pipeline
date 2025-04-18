############ EC2 SECURITY GROUP ##############
resource "aws_security_group" "ec2_security_group" {
  name        = "MskCDCEc2SecurityGroup"
  description = "Security Group for EC2 Instances"
  vpc_id      = data.aws_vpc.vpc_staging.id

  tags = {
    Name = "MSK-CDC-EC2-SecurityGroup"
  }
}


# allow access to ec2 from anywhere via ssh
resource "aws_security_group_rule" "ec2_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.cidr_public_allow_list
  security_group_id = aws_security_group.ec2_security_group.id
}


# allow ingress from anywhere to ec2 (because of schema regsitry)
resource "aws_security_group_rule" "ec2_ingress_all" {
  type              = "ingress"
  from_port         = 0              # Allow from port 0
  to_port           = 0              # Allow to port 65535 (all ports)
  protocol          = "-1"           # "-1" means all protocols
  cidr_blocks       = var.cidr_public_allow_list  # Allow from all public IPs
  security_group_id = aws_security_group.ec2_security_group.id
}

# allow ingress from msk to ec2 (because of schema regsitry)
resource "aws_security_group_rule" "ec2_msk_ingress_all" {
  type              = "ingress"
  from_port         = 0              # Allow from port 0
  to_port           = 0              # Allow to port 65535 (all ports)
  protocol          = "-1"           # "-1" means all protocols
  source_security_group_id = aws_security_group.msk_security_group.id  # Allow from all msk SG
  security_group_id = aws_security_group.ec2_security_group.id
}

# allow all traffic from ec2 into public internet
resource "aws_security_group_rule" "ec2_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_public_internet]
  security_group_id = aws_security_group.ec2_security_group.id
}

############ MSK SECURITY GROUP ##############
resource "aws_security_group" "msk_security_group" {
  name        = "MSKSecurityGroup"
  description = "Security Group for MSK Cluster"
  vpc_id      = data.aws_vpc.vpc_staging.id

  tags = {
    Name = "MSKSecurityGroup"
  }
}

# allow ingress on 2181 from ec2
resource "aws_security_group_rule" "msk_ingress_2181" {
  type                       = "ingress"
  from_port                  = 2181
  to_port                    = 2181
  protocol                   = "tcp"
  source_security_group_id   = aws_security_group.ec2_security_group.id
  security_group_id          = aws_security_group.msk_security_group.id
}

# allow ingress on 9092 from ec2
resource "aws_security_group_rule" "msk_ingress_9092" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.ec2_security_group.id
  security_group_id = aws_security_group.msk_security_group.id
}


resource "aws_security_group_rule" "msk_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.msk_security_group.id
}

# allow all traffic from msk reach the public internet
resource "aws_security_group_rule" "msk_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_public_internet]
  security_group_id = aws_security_group.msk_security_group.id
}



######### UPDATE THE RDS SECURITY GROUP Ingress rule #################
# allow ingress from msk
resource "aws_security_group_rule" "rds_ingress_5432_msk" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.msk_security_group.id
  security_group_id        = data.aws_security_group.rds_security_group.id
}

# allow ingress from ec2
resource "aws_security_group_rule" "rds_ingress_5432_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_security_group.id
  security_group_id        = data.aws_security_group.rds_security_group.id
}
