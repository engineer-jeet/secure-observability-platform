module "us_vpc" {

  source = "./modules/vpc"

  region_name = "us-east-1"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_1 = "10.0.1.0/24"
  public_subnet_2 = "10.0.2.0/24"

  private_subnet_1 = "10.0.11.0/24"
  private_subnet_2 = "10.0.12.0/24"
}

module "eu_vpc" {

  source = "./modules/vpc"

  providers = {
    aws = aws.eu
  }

  region_name = "eu-west-1"

  vpc_cidr = "10.1.0.0/16"

  public_subnet_1 = "10.1.1.0/24"
  public_subnet_2 = "10.1.2.0/24"

  private_subnet_1 = "10.1.11.0/24"
  private_subnet_2 = "10.1.12.0/24"
}

module "apac_vpc" {

  source = "./modules/vpc"

  providers = {
    aws = aws.apac
  }

  region_name = "ap-south-1"

  vpc_cidr = "10.2.0.0/16"

  public_subnet_1 = "10.2.1.0/24"
  public_subnet_2 = "10.2.2.0/24"

  private_subnet_1 = "10.2.11.0/24"
  private_subnet_2 = "10.2.12.0/24"
}

module "us_eks" {

  source = "./modules/eks"

  cluster_name = "us-observability-cluster"

  private_subnets = module.us_vpc.private_subnets
}