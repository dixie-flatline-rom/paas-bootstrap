resource "aws_route_table" "az1" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-nat-az1"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "az1" {
  subnet_id      = "${aws_subnet.az1.id}"
  route_table_id = "${aws_route_table.az1.id}"
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.az1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${var.nat_id}"
}
