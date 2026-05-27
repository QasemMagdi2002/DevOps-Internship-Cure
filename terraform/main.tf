module "networking" {
  source = "./modules/networking"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
  common_tags        = local.common_tags
}

module "s3" {
  source = "./modules/s3"

  bucket_name            = "${local.name_prefix}-documents-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  protect_data_resources = var.protect_data_resources
  common_tags            = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  name_prefix         = local.name_prefix
  cluster_version     = var.eks_cluster_version
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  common_tags         = local.common_tags
}

module "external_dns" {
  source = "./modules/external_dns"

  name_prefix               = local.name_prefix
  cluster_name              = module.eks.cluster_name
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  hosted_zone_id            = data.aws_route53_zone.root.zone_id
  root_domain_name          = var.root_domain_name
  common_tags               = local.common_tags

  depends_on = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  name_prefix            = local.name_prefix
  db_name                = var.db_name
  db_username            = var.db_username
  db_master_password     = var.db_master_password
  instance_class         = var.rds_instance_class
  allocated_storage      = var.rds_allocated_storage
  multi_az               = var.rds_multi_az
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  eks_node_sg_id         = module.eks.node_security_group_id
  protect_data_resources = var.protect_data_resources
  common_tags            = local.common_tags
}

module "irsa" {
  source = "./modules/irsa"

  name_prefix               = local.name_prefix
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  namespace                 = local.backend_namespace
  service_account_name      = "cure-backend-sa"
  s3_bucket_arn             = module.s3.bucket_arn
  common_tags               = local.common_tags
}

module "alb_controller" {
  source = "./modules/alb_controller"

  name_prefix               = local.name_prefix
  cluster_name              = module.eks.cluster_name
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  vpc_id                    = module.networking.vpc_id
  aws_region                = var.aws_region
  common_tags               = local.common_tags

  depends_on = [module.eks]
}

module "monitoring" {
  source = "./modules/monitoring"

  enable_monitoring = var.enable_monitoring
  cluster_name      = module.eks.cluster_name

  depends_on = [module.eks]
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "root" {
  name         = var.root_domain_name
  private_zone = false
}

module "acm" {
  source = "./modules/acm"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  root_zone_id           = data.aws_route53_zone.root.zone_id
  frontend_domain        = var.frontend_domain
  frontend_origin_domain = var.frontend_origin_domain
  backend_domain         = var.backend_domain
  common_tags            = local.common_tags
}

module "cloudfront" {
  source = "./modules/cloudfront"

  root_zone_id           = data.aws_route53_zone.root.zone_id
  frontend_domain        = var.frontend_domain
  frontend_origin_domain = var.frontend_origin_domain
  acm_certificate_arn    = module.acm.cloudfront_certificate_arn
  common_tags            = local.common_tags

  depends_on = [module.acm]
}
