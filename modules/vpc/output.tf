output "vpc_info" {
  value = {
    vpc = {
      id = aws_vpc.vpc.id
      arn = aws_vpc.vpc.id
      name = aws_vpc.vpc.tags.Name
      cidr_block = aws_vpc.vpc.cidr_block 
    },
    internet_gateway = {
      id = aws_internet_gateway.igw.id
      arn = aws_internet_gateway.igw.arn
      name = aws_internet_gateway.igw.tags.Name
      vpc_id = aws_internet_gateway.igw.vpc_id
    },
    private_subnets = {
      for subnet in aws_subnet.private_subnets: subnet.tags.Name => { 
        name = subnet.tags.Name
        id = subnet.id
        arn = subnet.arn
        cidr_block = subnet.cidr_block
      }
    },
    public_subnets = {
      for subnet in aws_subnet.public_subnets: subnet.tags.Name => { 
        name = subnet.tags.Name
        id = subnet.id
        arn = subnet.arn
        cidr_block = subnet.cidr_block
      }
    },
    nat_gateway = {
      type = "EC2_instance"
      id = aws_instance.nat_gateway.id
      arn = aws_instance.nat_gateway.arn
      name = aws_instance.nat_gateway.tags.Name
      nic_id = aws_network_interface.nat_gateway_nic.id
      nic_arn = aws_network_interface.nat_gateway_nic.arn
    },
    public_route_table = {
      id = aws_route_table.public_route_table.id
      arn = aws_route_table.public_route_table.arn
      name = aws_route_table.public_route_table.tags.Name
    },
    privater_route_table = {
      id = aws_route_table.private_route_table.id
      arn = aws_route_table.private_route_table.arn
      name = aws_route_table.private_route_table.tags.Name
    }

  }
  description = "The information about the newly created VPC"
}
