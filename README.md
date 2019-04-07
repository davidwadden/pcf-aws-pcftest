# pcf-aws-63r53rk54v0r

Group of PCF Foundations on AWS serving 63r53rk54v0r.com

## Summary

This repository contains the configuration required for an example deployment of PCF to `aws.pcftest.net`.

It describes the following foundations:
- `cp`: a Control Plane used to manage all foundations, documented [here](cp/README.md)
- `nonprod`: a PAS foundation for non-production workloads, documented [here](nonprod/README.md)

## Attribution

Terraforming code comes from the [`terraforming-aws`](https://github.com/pivotal-cf/terraforming-aws) repo.

## TODOs

- Deploy Control Plane Ops Manager with Platform Automation?
- Create S3 buckets in control plane terraforming
- Use RDS for database instead of internal
- Update certificates
- Base pas configuration, with operations capturing features?
- cert creation via terraform
- investigate what minimum set of alternative names the certs need