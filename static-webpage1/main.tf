
resource "aws_security_group" "terraform_sgp" {
  name        = "terraform-sg"
  description = "first Terraform-managed resource"
  vpc_id = var.vpc_id
  


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.58.18.40/32"]
  }
}

resource "aws_instance" "test_instance" {
    ami = var.ami 
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    security_groups = [aws_security_group.terraform_sgp.id]
    user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable nginx
    echo "<h1>Hello from Terraform!</h1>" > /usr/share/nginx/html/index.html
    systemctl start nginx
  EOF    
    
  
}

resource "aws_security_group" "alb_sg" {
  name        = "learn-terraform-alb-sg"
  description = "Allow HTTP from the internet to the ALB"
  vpc_id      = var.vpc_id

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
}

resource "aws_lb" "my_first_alb" {
  name               = "learn-terraform-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "my_first_tg" {
  name     = "learn-terraform-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_first_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_first_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "my_first_instance" {
  target_group_arn = aws_lb_target_group.my_first_tg.arn
  target_id        = aws_instance.my_first_instance.id
  port             = 80
}


