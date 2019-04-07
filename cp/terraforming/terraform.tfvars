env_name           = "cp"
region             = "us-east-1"
availability_zones = ["us-east-1a","us-east-1b"]
ops_manager_ami    = "ami-05d88dd438fac4a9b"
ops_manager_instance_type = "m5.xlarge"
ops_manager_private = false
ops_manager_vm     = true
rds_instance_count = 0
dns_suffix         = "aws.pcftest.net"
vpc_cidr           = "10.0.0.0/16"
use_route53        = true
contact_email      = "dwadden@pivotal.io"

tags = {
    Owner = "dwadden"
}
