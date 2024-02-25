resource "aws_vpc" "wexpress" {
  cidr_block           = var.vpc-cider
  instance_tenancy     = "default"
  enable_dns_support   = "false"
  enable_dns_hostnames = "false"
  tags = {
    Name = "${var.environment}-${var.service-name}"
  }
}

resource "aws_subnet" "pub-1c" {
  vpc_id            = aws_vpc.wexpress.id
  cidr_block        = var.pub-1c-cider
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.environment}-${var.service-name}-pub-1c"
  }
}
resource "aws_subnet" "pub-1d" {
  vpc_id            = aws_vpc.wexpress.id
  cidr_block        = var.pub-1d-cider
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "${var.environment}-${var.service-name}-pub-1d"
  }
  
}
resource "aws_subnet" "pri-1c" {
  vpc_id            = aws_vpc.wexpress.id
  cidr_block        = var.pri-1c-cider
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.environment}-${var.service-name}-pri-1c"
  }
  
}
resource "aws_subnet" "pri-1d" {
  vpc_id            = aws_vpc.wexpress.id
  cidr_block        = var.pri-1d-cider
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "${var.environment}-${var.service-name}-pri-1d"
  }
  
}
resource "aws_subnet" "db-1c" {
  vpc_id            = aws_vpc.wexpress.id
  cidr_block        = var.db-1c-cider
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.environment}-${var.service-name}-db-1c"
  }
  
}
resource "aws_subnet" "db-1d" {
  vpc_id            = aws_vpc.wexpress.id
  cidr_block        = var.db-1d-cider
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "${var.environment}-${var.service-name}-db-1d"
  }
  
}

resource "aws_internet_gateway" "wexpress" {
  vpc_id = aws_vpc.wexpress.id
  tags = {
    Name = "${var.environment}-${var.service-name}-igw"
  }
}
# 節約コメントアウト
# resource "aws_eip" "nat-gw-1c" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.environment}-${var.service-name}-nat-1c"
#   }
# }
# resource "aws_nat_gateway" "nat-gw-1c" {
#   allocation_id = "${aws_eip.nat-gw-1c.id}"
#   subnet_id     = "${aws_subnet.pub-1c.id}"
#   tags = {
#     Name = "${var.environment}-${var.service-name}-nat-1c"
#   }
# }
# resource "aws_eip" "nat-gw-1d" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.environment}-${var.service-name}-nat-1d"
#   }
# }
# resource "aws_nat_gateway" "nat-gw-1d" {
#   allocation_id = "${aws_eip.nat-gw-1d.id}"
#   subnet_id     = "${aws_subnet.pub-1d.id}"
#   tags = {
#     Name = "${var.environment}-${var.service-name}-nat-1d"
#   }
# }

resource "aws_default_route_table" "wexpress" {
  default_route_table_id = aws_vpc.wexpress.default_route_table_id

  tags = {
    Name = "${var.environment}-${var.service-name}-default"
  }
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.wexpress.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wexpress.id
  }
  tags = {
    Name = "${var.environment}-${var.service-name}-pub"
  }
}
resource "aws_route_table" "pri-1c" {
  vpc_id = aws_vpc.wexpress.id
  route {
    cidr_block = "0.0.0.0/0"
    # 節約コメントアウト
    # nat_gateway_id = aws_nat_gateway.nat-gw-1c.id
    gateway_id = aws_internet_gateway.wexpress.id
  }
  tags = {
    Name = "${var.environment}-${var.service-name}-pri-1c"
  }
}
resource "aws_route_table" "pri-1d" {
  vpc_id = aws_vpc.wexpress.id
  route {
    cidr_block = "0.0.0.0/0"
    # 節約コメントアウト
    # nat_gateway_id = aws_nat_gateway.nat-gw-1d.id
    gateway_id = aws_internet_gateway.wexpress.id
  }
  tags = {
    Name = "${var.environment}-${var.service-name}-pri-1d"
  }
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.wexpress.id
  tags = {
    Name = "${var.environment}-${var.service-name}-db"
  }
}

resource "aws_route_table_association" "pub-1c" {
  subnet_id      = aws_subnet.pub-1c.id
  route_table_id = aws_route_table.pub.id
}
resource "aws_route_table_association" "pub-1d" {
  subnet_id      = aws_subnet.pub-1d.id
  route_table_id = aws_route_table.pub.id
}
resource "aws_route_table_association" "pri-1c" {
  subnet_id      = aws_subnet.pri-1c.id
  route_table_id = aws_route_table.pri-1c.id
}
resource "aws_route_table_association" "pri-1d" {
  subnet_id      = aws_subnet.pri-1d.id
  route_table_id = aws_route_table.pri-1d.id
}
resource "aws_route_table_association" "db-1c" {
  subnet_id      = aws_subnet.db-1c.id
  route_table_id = aws_route_table.db.id
}
resource "aws_route_table_association" "db-1d" {
  subnet_id      = aws_subnet.db-1d.id
  route_table_id = aws_route_table.db.id
}
