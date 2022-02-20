output "Docker-Main-Node-Public-IP" {
  value = aws_instance.docker-master.public_ip
}

output "Docker-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.docker-worker :
    instance.id => instance.public_ip
  }
}
