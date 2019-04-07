env_name           = "nonprod"
region             = "us-east-1"
availability_zones = ["us-east-1a","us-east-1b"]
ops_manager_ami    = ""
rds_instance_count = 0
dns_suffix         = "aws.pcftest.net"
vpc_cidr           = "10.0.0.0/16"
use_route53        = true
contact_email      = "dwadden@pivotal.io"

tags = {
    Owner = "dwadden"
    Foundation = "nonprod"
}
