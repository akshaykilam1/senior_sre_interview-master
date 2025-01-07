module "ecr" {
  source = "./ecr"

  repository_name     = "simpsons-simulator"
  image_tag_mutability = "IMMUTABLE"
  encryption_type      = "AES256"
  tags = {
    Environment = "Prod"
    Project     = "SimpsonsSimulator"
  }
}


module "vpc" {
  source = "./vpc"

  # VPC Configuration
  vpc_name = "simpsons-vpc"
  cidr     = "10.0.0.0/16"

  # Subnet Configuration
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Availability Zones
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # NAT Gateway Configuration
  enable_nat_gateway   = true
  single_nat_gateway   = true
}

module "ecs" {
  source                 = "./ecs"
  cluster_name           = "simpsons-cluster"
  service_name           = "simpsons-service"
  task_definition_name   = "simpsons-task"
  image_url              = "676206917629.dkr.ecr.us-east-1.amazonaws.com/simpsons-simulator:latest"
  container_port         = 4567
  vpc_id                 = module.vpc.vpc_id
  private_subnets        = module.vpc.private_subnets
}

module "alb" {
  source                 = "./alb"
  vpc_id                 = module.vpc.vpc_id
  public_subnets         = module.vpc.public_subnets
  listener_port          = 443
  target_group_port      = 4567
  target_group_protocol  = "HTTP"
  certificate_arn        = "arn:aws:acm:us-east-1:676206917629:certificate/130d66d8-0867-4ba5-bdfa-3c207037bf26"
  ecs_service_arn        = module.ecs.service_arn
}
