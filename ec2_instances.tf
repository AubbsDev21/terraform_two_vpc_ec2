#Getting Linux AMI ID using SSM Parameter endpoint in us-east-1 (master)
data "aws_ssm_parameter" "linuxAmiMaster" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Get Linux AMI ID using SSM Parameter endpoint in us-west-2 (Workers)
data "aws_ssm_parameter" "linuxAmiWork" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Creating key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "Docker"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Creating key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider   = aws.region-worker
  key_name   = "Docker"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Creating EC2 in us-east-1
resource "aws_instance" "docker-master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmiMaster.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1_master.id

  tags = {
    Name = "docker_master_tf"
  }

  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]
}


#Create EC2 in us-west-2
resource "aws_instance" "docker-worker" {
  provider                    = aws.region-worker
  count                       = var.workers-count
  ami                         = data.aws_ssm_parameter.linuxAmiWork.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.worker-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg-worker.id]
  subnet_id                   = aws_subnet.subnet_2_master.id

  tags = {
    Name = join("_", ["docker_worker_tf", count.index + 1])
  }
  depends_on = [aws_main_route_table_association.set-worker-default-rt-assoc, aws_instance.docker-master]
}








