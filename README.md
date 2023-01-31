# Plex Media Server on AWS using Spot Instances and S3 for Media Storage

## Prerequisites
 * AWS Account: https://console.aws.amazon.com/
 * Packer: https://developer.hashicorp.com/packer/downloads
 * Terraform: https://developer.hashicorp.com/terraform/downloads
 * AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
 * Valid AWS Credentials: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

## Deployment Steps

1. Run Packer to create your AMI
2. Run Terraform

## Packer

This Packer configuration will install the necessary software to run Plex Media Server in a Docker Container as well as s3fs-fuse which gives you the ability have a FUSE-based file system backed by Amazon S3.

* https://hub.docker.com/r/plexinc/pms-docker/
* https://github.com/s3fs-fuse/s3fs-fuse

### Running Packer (current only x86 available)

~~There are two different configurations, one for the x86 architecture and one for the ARM architecture.~~

Update the AMI name in the json file, so it is unique by updating the suffix in the format of YYYYMMDD for the date.

After changing into the packer directory run one of the following commands to build your AMI:

x86:
```packer build .\plex-x86_64.json```

~~ARM:~~
~~```packer build .\plex-arm64.json```~~

## Plex Claim Token

Get Plex Claim Token: https://www.plex.tv/claim

The Claim Token is only good for a few minutes, so it is easiest to not set this variable and let Terraform prompt you for it.

## Running Terraform

First, make sure you've run `terraform init` on your repo.

Then run `terraform plan` and if it is going to do what you expect run `terraform apply`.

## After your server is done spinning up

### If the plex app cannot connect to your server

* Go to http://{ip}:32400/web
* Settings -> Remote Access -> Enable Remote Access
    * Check Specify Port (leave the port the same) and retry

### Create Libraries

* Go to Manage -> Libraries
    * Create libraries seleting folders within the /plex-data folder

### Minimize EBS and S3 API Requests to Reduce Cost

To avoid scanning of the files in the S3 bucket (meaning additional S3 api requests and additional EBS i/o requests -> additional cost)
 * Don't set Plex to periodically scan library
 * Turn off scheduled tasks that will scan the library - I leave on the following
   * Backup database every three days
   * Optimize database every week
   * Remove old bundles every week
   * Remove old cache files every week
   * Upgrade media analysis during maintenance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.30 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_plex_autoscaling"></a> [plex\_autoscaling](#module\_plex\_autoscaling) | terraform-aws-modules/autoscaling/aws | ~> 6.5 |
| <a name="module_s3_plex_db"></a> [s3\_plex\_db](#module\_s3\_plex\_db) | terraform-aws-modules/s3-bucket/aws | ~> 3.3 |
| <a name="module_s3_plex_storage"></a> [s3\_plex\_storage](#module\_s3\_plex\_storage) | terraform-aws-modules/s3-bucket/aws | ~> 3.3 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.14 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.plex_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_security_group.plex_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.plex_claim_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.plex](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.plex_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"eu-central-1"` | no |
| <a name="input_instance_storage_size"></a> [instance\_storage\_size](#input\_instance\_storage\_size) | Size for EC2 EBS root volume | `number` | `30` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Type of EC2 instance | `string` | `"t3a.micro"` | no |
| <a name="input_plex_claim_token"></a> [plex\_claim\_token](#input\_plex\_claim\_token) | Token to claim your plex media server.  You can get this by going to https://www.plex.tv/claim. | `string` | n/a | yes |
| <a name="input_plex_libraries"></a> [plex\_libraries](#input\_plex\_libraries) | List of Plex libraries | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
