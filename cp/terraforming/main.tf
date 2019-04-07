provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"

  version = "~> 1.60"
}

terraform {
  required_version = "< 0.12.0"

  backend "s3" {
    bucket = "dwadden-platform-state"
    key    = "cp/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.2"
}

resource "random_integer" "bucket" {
  min = 1
  max = 100000
}

module "infra" {
  source = "../../terraform/modules/infra"

  region             = "${var.region}"
  env_name           = "${var.env_name}"
  availability_zones = "${var.availability_zones}"
  vpc_cidr           = "${var.vpc_cidr}"

  hosted_zone = "${var.hosted_zone}"
  dns_suffix  = "${var.dns_suffix}"
  use_route53 = "${var.use_route53}"

  internetless = false
  tags         = "${local.actual_tags}"
}

module "ops_manager" {
  source = "../../terraform/modules/ops_manager"

  vm_count       = "${var.ops_manager_vm ? 1 : 0}"
  optional_count = "${var.optional_ops_manager ? 1 : 0}"
  subnet_id      = "${local.ops_man_subnet_id}"

  env_name      = "${var.env_name}"
  region        = "${var.region}"
  ami           = "${var.ops_manager_ami}"
  optional_ami  = "${var.optional_ops_manager_ami}"
  instance_type = "${var.ops_manager_instance_type}"
  private       = "${var.ops_manager_private}"
  vpc_id        = "${module.infra.vpc_id}"
  vpc_cidr      = "${var.vpc_cidr}"
  dns_suffix    = "${var.dns_suffix}"
  zone_id       = "${module.infra.zone_id}"
  use_route53   = "${var.use_route53}"

  # additional_iam_roles_arn = ["${module.pas.iam_pas_bucket_role_arn}"]
  bucket_suffix = "${local.bucket_suffix}"

  tags = "${local.actual_tags}"
}

module "control_plane" {
  source                  = "../../terraform/modules/control_plane"
  vpc_id                  = "${module.infra.vpc_id}"
  env_name                = "${var.env_name}"
  availability_zones      = "${var.availability_zones}"
  vpc_cidr                = "${var.vpc_cidr}"
  public_subnet_ids       = "${module.infra.public_subnet_ids}"
  private_route_table_ids = "${module.infra.deployment_route_table_ids}"
  tags                    = "${local.actual_tags}"
  region                  = "${var.region}"
  dns_suffix              = "${var.dns_suffix}"
  zone_id                 = "${module.infra.zone_id}"
  use_route53             = "${var.use_route53}"
}

module "rds" {
  source = "../../terraform/modules/rds"

  rds_db_username    = "${var.rds_db_username}"
  rds_instance_class = "${var.rds_instance_class}"
  rds_instance_count = "${var.rds_instance_count}"

  engine         = "postgres"
  engine_version = "9.6.10"
  db_port        = 5432

  env_name           = "${var.env_name}"
  availability_zones = "${var.availability_zones}"
  vpc_cidr           = "${var.vpc_cidr}"
  vpc_id             = "${module.infra.vpc_id}"

  tags = "${local.actual_tags}"
}

resource "null_resource" "create_databases" {
  count = "${var.rds_instance_count == 1 ? 1 : 0}"

  provisioner "local-exec" {
    command     = "./db/create_databases.sh"
    interpreter = ["bash", "-c"]

    environment {
      OPSMAN_URL         = "${module.ops_manager.public_ip}"
      OPSMAN_PRIVATE_KEY = "${module.ops_manager.ssh_private_key}"

      RDS_DB_NAME  = "${module.rds.rds_db_name}"
      RDS_PORT     = "${module.rds.rds_port}"
      RDS_ADDRESS  = "${module.rds.rds_address}"
      RDS_USERNAME = "${module.rds.rds_username}"
      RDS_PASSWORD = "${module.rds.rds_password}"
    }
  }
}

# Let's Encrypt certs
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.contact_email}"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = "${acme_registration.reg.account_key_pem}"
  common_name               = "${var.env_name}.${var.dns_suffix}"
  subject_alternative_names = [
    "pcf.${var.env_name}.${var.dns_suffix}",
    "plane.${var.env_name}.${var.dns_suffix}"
  ]

  dns_challenge {
    provider = "route53"

    config {
      AWS_HOSTED_ZONE_ID = "${module.infra.aws_dns_zone_id}"
    }
  }
}