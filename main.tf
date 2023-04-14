
## VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "harshuvpc"
  }
}

## Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "harshu-igw"
  }
}

## Public-subnet1

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "pubsub1"
  }
}

##Private-subnet1

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "prisub1"
  }
}

##public-subnet2

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "pubsub2"
  }
}


##private-subnet2

resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "prisub2"
  }
}


##RouteTable-Public1

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "PublicRT1"
  }
}


## RouteTable-public2


resource "aws_route_table" "public-route-table2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "PublicRT2"
  }
}



##Associate public subnet1 with public Route table1



resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public-route-table.id

}


## Associate public subnet2 with public Route tabel2

resource "aws_route_table_association" "public-subnet-route-table1-association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public-route-table2.id

}


# Elastic IP for NAT Gateway1


resource "aws_eip" "eip-for-Nat-gateway-1" {
  vpc = true

  tags = {
    Name = "EIP1"
  }
}


## Elastic IP for NAT Gateway2

resource "aws_eip" "eip-for-Nat-gateway-2" {
  vpc = true

  tags = {
    Name = "EIP2"
  }
}



## Create NAT GATEWAY in Public subnet1

resource "aws_nat_gateway" "nat-gateway-1" {
  allocation_id = aws_eip.eip-for-Nat-gateway-1.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT1"
  }
}

## Create NAT GATEWAY in public subnet2

resource "aws_nat_gateway" "nat-gateway-2" {
  allocation_id = aws_eip.eip-for-Nat-gateway-2.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "NAT2"
  }
}


## Create private route table1 and Add route Through NAT Gateway1

resource "aws_route_table" "private-route-table-1" {
  vpc_id = aws_vpc.main.id

  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-1.id

  }

  tags = {
    Name = "PrivateRT1"
  }
}



## Associate private subnet1 with private Route Table1

resource "aws_route_table_association" "private-subnet-route-table1-association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private-route-table-1.id

}


## create private route table2 with Add route Through NAT Gateway

resource "aws_route_table" "private-route-table-2" {
  vpc_id = aws_vpc.main.id

  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-2.id

  }

  tags = {
    Name = "PrivateRT2"
  }
}

## Associate Private subnet2 with private Route Table2

resource "aws_route_table_association" "private-subnet-route-table2-association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private-route-table-2.id
  }
