output "vpc_id" {
    value = aws_vpc.vpc.id
    description = "The ID of the newly created VPC"
}

output "vpc_arn" {
    value = aws_vpc.vpc.arn
    description = "The ARN of the newly create VPC"
}

output "vpc_cidr" {
    value = aws_vpc.vpc.cidr_block 
    description = "The CIDR block for the newly created VPC"
}