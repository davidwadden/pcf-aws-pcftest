env_name           = "nonprod"
region             = "us-west-1"
availability_zones = ["us-west-1b", "us-west-1c"]
ops_manager_ami    = ""
rds_instance_count = 0
dns_suffix         = "aws.pcftest.net"
vpc_cidr           = "10.0.0.0/16"
use_route53        = true
contact_email      = "aneumann@pivotal.io"

tags = {
    created_by = "aneumann"
    env_name = "nonprod"
}