resource "aws_vpc" "Demo_vpc" {
    cidr_block = "10.0.0.0/25"
    tags = {
      Name = "Demo_VPC"
  }
}

resource "aws_default_route_table" "RT_PUBLIC" {
  default_route_table_id = "${aws_vpc.Demo_vpc.default_route_table_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
 
  }
   tags = {
    Name = "RT_PUBLIC"
    }
}

resource "aws_route_table_association" "RT_ASSOSIATION_PUBLIC-1" {
  subnet_id      = "${aws_subnet.PUBLIC_SUBNET-1.id}"
  route_table_id = "${aws_default_route_table.RT_PUBLIC.id}"
}
resource "aws_route_table_association" "RT_ASSOSIATION_PUBLIC-2" {
  subnet_id      = "${aws_subnet.PUBLIC_SUBNET-2.id}"
  route_table_id = "${aws_default_route_table.RT_PUBLIC.id}"
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.Demo_vpc.id}"
  tags = {
    Name = "Demo"
  }
}

resource "aws_security_group" "SERVER_SG"{
    vpc_id = "${aws_vpc.Demo_vpc.id}"
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "SERVER_SG"
    }
  
}
resource "aws_subnet" "PUBLIC_SUBNET-1"{
    vpc_id = "${aws_vpc.Demo_vpc.id}"
    cidr_block = "10.0.0.0/28"
    availability_zone = "us-east-2a"
    tags = {
      subnet = "PUBLIC"
      Name = "PUBLIC_SUBNET-1"
    }
}
resource "aws_subnet" "PUBLIC_SUBNET-2"{
    vpc_id = "${aws_vpc.Demo_vpc.id}"
    cidr_block = "10.0.0.16/28"
    availability_zone = "us-east-2b"
    tags = {
      subnet = "PUBLIC"
      Name = "PUBLIC_SUBNET-2"
    }
}

resource "aws_instance" "SERVER" {
  ami           = "ami-0a63f96e85105c6d3"
  instance_type = "t2.micro"
  subnet_id     =   "${aws_subnet.PUBLIC_SUBNET-1.id}"
  security_groups = ["${aws_security_group.SERVER_SG.id}"]
  key_name = "my-key"
  associate_public_ip_address = true
  user_data = "${file("./script.sh")}"

  tags = {
    Name = "Demo"
  }
}

resource "aws_route53_zone" "ROUTE_53" {
    name = "jaggadeshdemo.ml"
}
resource "aws_elb" "ELB" {
    name = "ELB"
    subnets = ["${aws_subnet.PUBLIC_SUBNET-1.id}", "${aws_subnet.PUBLIC_SUBNET-2.id}"]
    security_groups = ["${aws_security_group.SERVER_SG.id}"]
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    cross_zone_load_balancing = true
}
resource "aws_elb_attachment" "baz" {
  elb      = "${aws_elb.ELB.id}"
  instance = "${aws_instance.SERVER.id}"
}
resource "aws_route53_record" "RECORD_SET" {
    zone_id = "${aws_route53_zone.ROUTE_53.id}"
    name    = "jaggadeshdemo.ml"
    type    = "A"

    alias {
        name                   = "${aws_elb.ELB.dns_name}"
        zone_id                = "${aws_elb.ELB.zone_id}"
        evaluate_target_health = true
    }
}
