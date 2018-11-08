variable "cluster_name" {
  default = "hongkliu-tf"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "worker" {
  ami           = "ami-c6e27cbe"
  instance_type = "t2.micro"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    "Name" = "${var.cluster_name}-worker-${count.index + 1}"
  }
  count = 1
}

resource "aws_instance" "master" {
  ami           = "ami-c6e27cbe"
  instance_type = "t2.micro"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    "Name" = "${var.cluster_name}-master-${count.index + 1}"
  }
  count = 1
}
