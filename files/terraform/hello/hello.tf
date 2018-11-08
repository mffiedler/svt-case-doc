provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "hongkliu-tf-example" {
  ami           = "ami-c6e27cbe"
  instance_type = "t2.micro"
}