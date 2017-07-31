# Terraform AWS

This repository contains a Terraform project that builds VPC
with 2 Public, 2 Private Subnets, Nat Instance, 2 Web Instances and 3 DB instances.

## Terraform Version
```
Terraform v0.9.11
```

## Usage
```
`terraform.tfvars` contain's variables which should be override with valid values.
```
### Plan

```
terraform plan -var-file terraform.tfvars
```

### Apply

```
terraform apply -var-file terraform.tfvars
```

### Destroy

```
terraform destroy -var-file terraform.tfvars
```

### Access to instances thru the ssh

```
ssh ec2-user@nat-instance-elastic-ip -i /path/to/private_ssh_key

ssh ubuntu@instance-private-ip -i ~/.ssh/vfq_id_rsa.private
```

[Terraform]: http://terraform.io
[AWS documentation]: http://aws.amazon.com/documentation/
