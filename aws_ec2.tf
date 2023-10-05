# EC2 Instance
resource "aws_instance" "food-web" {
  ami           = "ami-067d1e60475437da2"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.food-pub-sn.id
  vpc_security_group_ids = [aws_security_group.food-pub-sg.id]
  key_name = "sushma.new"
  user_data = file("food.sh")
  tags = {
    Name = "food-server"
  }
}