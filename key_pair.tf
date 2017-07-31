resource "aws_key_pair" "deployer" {
  key_name   = "${var.aws_key_name}"
  public_key = "${ file("${var.aws_key_path}")}"
}