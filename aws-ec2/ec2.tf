resource "aws_instance" "webserver" {
  # provider = aws.souravprofile
  ami           = var.ami
  instance_type = var.instancetype
  tags = {
    Name = "${var.web_server} webserver"
  }
 }