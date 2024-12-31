terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
  }

  required_version = ">= 1.5.5"
}

provider "aws" {
  region     = var.region
  access_key = var.aws_credentials["access_key"]
  secret_key = var.aws_credentials["secret_key"]
  token      = var.aws_credentials["token"]
}

### VPC ###

resource "aws_vpc" "eventtom_vpc" {
  cidr_block           = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "eventtom_vpc"
  }
}
resource "aws_subnet" "eventtom_public_subnet" {
  vpc_id     = aws_vpc.eventtom_vpc.id
  cidr_block = cidrsubnet(aws_vpc.eventtom_vpc.cidr_block, 4, 10)
  ipv6_cidr_block = cidrsubnet(aws_vpc.eventtom_vpc.ipv6_cidr_block,8,0)
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eventtom_private_subnet" {
  vpc_id     = aws_vpc.eventtom_vpc.id
  cidr_block = cidrsubnet(aws_vpc.eventtom_vpc.cidr_block, 4, 11)
  ipv6_cidr_block = cidrsubnet(aws_vpc.eventtom_vpc.ipv6_cidr_block,8,1)
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "eventtom-private-subnet"
  }

}

resource "aws_eip" "nat_gateway_eip" {
  # will be set automatically
  #domain = "vpc"

  tags = {
    Name = "eventtom_nat_gateway"
  }
}

resource "aws_internet_gateway" "eventtom_igw" {
  vpc_id = aws_vpc.eventtom_vpc.id

  tags = {
    Name = "eventtom_igw"
  }
}

resource "aws_nat_gateway" "eventtom_nat_gateway" {
  depends_on = [aws_internet_gateway.eventtom_igw]
  connectivity_type = "public"
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id = aws_subnet.eventtom_public_subnet.id
}

resource "aws_route_table" "eventtom_public" {
  vpc_id = aws_vpc.eventtom_vpc.id

  route {
    gateway_id = aws_internet_gateway.eventtom_igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "eventom_public"
  }
}

resource "aws_route_table" "eventtom_private" {
  vpc_id = aws_vpc.eventtom_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eventtom_nat_gateway.id
  }
  tags = {
    Name = "eventtom_private"
  }
}

resource "aws_route_table_association" "eventtom_public" {
  subnet_id      = aws_subnet.eventtom_public_subnet.id
  route_table_id = aws_route_table.eventtom_public.id
}

resource "aws_route_table_association" "eventtom_private" {
  subnet_id      = aws_subnet.eventtom_private_subnet.id
  route_table_id = aws_route_table.eventtom_private.id

}

resource "aws_db_subnet_group" "eventom" {
  name = "eventtom-postgres-subnet-group"
  subnet_ids = [
    aws_subnet.eventtom_private_subnet.id,
  ]
}


resource "aws_route" "ipv6_public_route" {
  route_table_id  = aws_route_table.eventtom_public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id      = aws_internet_gateway.eventtom_igw.id
}

### Security groups

resource "aws_security_group" "sg_eventtom_ec2" {
  name = "eventtom_ssh_sg"
  vpc_id = aws_vpc.eventtom_vpc.id
}

resource "aws_security_group_rule" "allow_ssh_traffic_to_ec2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sg_eventtom_ec2.id
}

# TODO need to be removed
resource "aws_security_group_rule" "allow_http_traffic_to_ec2" {
  description       = "Allow HTTP inbound traffic"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sg_eventtom_ec2.id

}

# TODO need to be removed
resource "aws_security_group_rule" "allow_https_traffic_to_ec2" {
  description       = "Allow HTTPS inbound traffic"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sg_eventtom_ec2.id

}

resource "aws_security_group_rule" "allow_all_outbound_traffic_from_ec2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sg_eventtom_ec2.id
}

resource "aws_security_group_rule" "allow_request_traffic_ec2" {
  type = "ingress"
  from_port = 8000
  to_port = 8000
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.sg_eventtom_ec2.id
}

resource "aws_security_group_rule" "allow_postgres_traffic_ec2" {
    type = "egress"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    source_security_group_id = aws_security_group.sg_eventtom_rds.id
    security_group_id = aws_security_group.sg_eventtom_ec2.id
  }

resource "aws_security_group_rule" "allow_redis_traffic_ec2" {
    type            = "egress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = aws_security_group.sg_eventtom_redis_rds.id
  security_group_id = aws_security_group.sg_eventtom_ec2.id

}

resource "aws_security_group" "sg_eventtom_rds" {
  name = "eventtom-rds-sg"
  vpc_id = aws_vpc.eventtom_vpc.id
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = []
    security_groups = [aws_security_group.sg_eventtom_ec2.id]
    ipv6_cidr_blocks = []
  }
  egress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "eventtom-redis-subnet-group"
  subnet_ids = [aws_subnet.eventtom_private_subnet.id]
}

resource "aws_security_group" "sg_eventtom_redis_rds" {
  name = "eventtom_redis_rds_sg"
  vpc_id = aws_vpc.eventtom_vpc.id

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    security_groups = [aws_security_group.sg_eventtom_ec2.id]
  }
  egress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
  }
}

resource "aws_security_group" "sg_eventtom_alb" {
  name   = "load_balancer_sg"
  vpc_id = aws_vpc.eventtom_vpc.id

  # TODO remove
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO remove
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load_balancer_sg"
  }
}

#### RDS ####

resource "aws_secretsmanager_secret" "eventtom_rds_password" {
  name                    = "EVENTTOM_RDS_PASSWORD"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "eventtom_secret_manager" {
  secret_id = aws_secretsmanager_secret.eventtom_rds_password.id

  secret_string = var.EVENTTOM_RDS_PASSWORD

  depends_on = [aws_secretsmanager_secret.eventtom_rds_password]

}

resource "aws_db_instance" "eventtom_rds" {
  identifier           = "eventtom-rds"
  db_name              = "eventtom"
  username = "postgres"
  password             = aws_secretsmanager_secret_version.eventtom_secret_manager.secret_string
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.postgres16"
  skip_final_snapshot = true
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.sg_eventtom_rds.id]
  db_subnet_group_name = aws_db_subnet_group.eventom.name
}

resource "aws_elasticache_cluster" "eventtom_redis" {
  cluster_id           = "eventtom-cluster"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.sg_eventtom_redis_rds.id]
}

#### Cloudfront ####

resource "aws_cloudfront_origin_access_identity" "eventtom_cloudfront_aoi" {
  comment = "OAI for the Flutter Web App Frontend"
}

resource "aws_cloudfront_distribution" "eventtom_flutter_distribution" {
  origin {
    domain_name = aws_s3_bucket.eventtom_s3.bucket_regional_domain_name
    origin_id   = "S3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.eventtom_cloudfront_aoi.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "S3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  custom_error_response {
    error_code          = 404
    response_code       = 200
    response_page_path  = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "eventtom_flutter_distribution"
  }
}


#### Application Load Balancer #####
resource "aws_lb" "eventtom_backend_alb" {
  name               = "eventom-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_eventtom_alb.id]
  subnets            = [aws_subnet.eventtom_public_subnet.id]
  ip_address_type = "dualstack"
}

resource "aws_lb_target_group" "eventtom_backend_alb_tg" {
  name     = "eventtom-backend-alb-tg"
  port     = 8000
  protocol = "tcp"
  vpc_id   = aws_vpc.eventtom_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/health"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "eventtom_alb_listener" {
  load_balancer_arn = aws_lb.eventtom_backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eventtom_backend_alb_tg.arn
  }
}

##### S3 #####

resource "aws_s3_bucket" "eventtom_s3" {
  bucket_prefix = var.S3_BUCKET_PREFIX
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "eventtom_s3_access" {
  bucket = aws_s3_bucket.eventtom_s3.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "eventtom_s3_owner" {
  bucket = aws_s3_bucket.eventtom_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.eventtom_s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.eventtom_cloudfront_aoi.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "eventtom_s3_policy" {
  bucket = aws_s3_bucket.eventtom_s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

#### EC2 ####

data "aws_iam_instance_profile" "vocareum_lab_instance_profile" {
  name = "LabInstanceProfile"
}


resource "aws_instance" "eventtom_ec2" {
  depends_on = [
    aws_db_instance.eventtom_rds,
    aws_s3_bucket.eventtom_s3,
    aws_elasticache_cluster.eventtom_redis,
    aws_vpc.eventtom_vpc,
    aws_internet_gateway.eventtom_igw,
    aws_nat_gateway.eventtom_nat_gateway,
    aws_subnet.eventtom_public_subnet
  ]
  ami = var.ami_ubuntu_2024LTS
  instance_type        = var.instance_type.micro
  vpc_security_group_ids = [aws_security_group.sg_eventtom_ec2.id]
  subnet_id = aws_subnet.eventtom_public_subnet.id
  associate_public_ip_address = false
  key_name             = var.laptop_linux_keypair
  iam_instance_profile = data.aws_iam_instance_profile.vocareum_lab_instance_profile.name

  user_data = <<-EOF
  git clone https://github.com/Flashwar/EventTom.git
  cd EventTom
  echo "export SECRET_KEY=${var.SECRET_KEY_DJANGO}" >> /etc/environment
  echo "export REDIS_SERVERIP=${aws_elasticache_cluster.eventtom_redis.cache_nodes[0].address}" >> /etc/environment
  echo "export DATABASE_URL=postgresql://${aws_db_instance.eventtom_rds.username}:${aws_secretsmanager_secret_version.eventtom_secret_manager.secret_string}@${aws_db_instance.eventtom_rds.address}:5432/${aws_db_instance.eventtom_rds.db_name}" >> /etc/environment
  echo "export WEBSITE_HOSTNAME=${aws_lb.eventtom_backend_alb.dns_name}"" >> /etc/environment
  pip3 install -r requirements.txt
  python3 manage.py migrate
  python3 manage.py runserver 0.0.0.0:8000
  EOF

}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.eventtom_backend_alb_tg.arn
  target_id        = aws_instance.eventtom_ec2.id
  port             = 8000
}
