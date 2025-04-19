# create key-pair
resource "tls_private_key" "msk_ec2_rsa_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "msk_ec2_key" {
  key_name   = "msk-cdc-terraform"
  public_key = tls_private_key.msk_ec2_rsa_private_key.public_key_openssh
}

resource "local_file" "ec2_pem_key_file" {
    content  = tls_private_key.msk_ec2_rsa_private_key.private_key_pem
    filename = "${path.module}/msk-cdc-terraform.pem"
}

# create ec2 instance, instance profile, and attach profile to ec2
# Create an IAM instance profile for the role
resource "aws_iam_instance_profile" "kafka_connect_instance_profile" {
  name = "kafkaConnectInstanceProfile"
  role = aws_iam_role.kafka_connect_role_ec2.name
}

# Attach the instance profile to the EC2 instance
resource "aws_instance" "cdc_demo_ec2" {
  ami               = local.ec2_ami
  instance_type     = local.ec2_instance_type
  tags = {
    Name = "cdc-demo-ec2"
  }
  key_name                  = aws_key_pair.msk_ec2_key.key_name
  associate_public_ip_address = true  # Enable public IP
  subnet_id                 = data.aws_subnet.public_subnet_1.id
  vpc_security_group_ids    = [aws_security_group.ec2_security_group.id]
  iam_instance_profile      = aws_iam_instance_profile.kafka_connect_instance_profile.name

  # Explicitly depend on the MSK cluster
  depends_on = [aws_msk_cluster.cdc_poc_msk_cluster]
    
}

