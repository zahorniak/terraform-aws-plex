# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform module that deploys Plex Media Server on AWS using EC2 Spot Instances with S3-backed media storage (s3fs-fuse) and Docker. Runs Plex as a systemd-managed Docker container on Amazon Linux 2.

## Common Commands

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Run all pre-commit hooks (formatting, validation, docs, linting)
pre-commit run -a

# Generate/update README documentation tables
terraform-docs markdown . --lockfile=false
```

There are no automated tests. Validation is done via `terraform validate` and `tflint` through pre-commit hooks.

## Architecture

The module provisions a complete single-instance Plex deployment:

- **VPC** (`vpc.tf`): `10.0.0.0/16` CIDR, 3 public + 3 private subnets, no NAT gateway
- **EC2** (`autoscaling.tf`): Single Spot instance via ASG with rolling refresh, Amazon Linux 2 AMI
- **Storage** (`s3.tf`): Single S3 storage bucket with folder-based library prefixes + one DB backup bucket, all using INTELLIGENT_TIERING
- **IAM** (`iam.tf`): Instance profile with S3 and SSM access
- **Security** (`sg.tf`): Port 32400 open for Plex access
- **Secrets** (`ssm.tf`): Plex claim token stored as SecureString in SSM Parameter Store
- **Bootstrap** (`templates/userdata.sh`): Installs Docker/s3fs, mounts S3 buckets, starts Plex container as systemd service

Subnet CIDRs are computed dynamically in `locals.tf` using `cidrsubnets()`.

## Key Dependencies

- **Terraform**: `>= 1.5.7`
- **AWS Provider**: `>= 6.29`
- **Public modules**: `terraform-aws-modules/vpc/aws ~> 6.6`, `terraform-aws-modules/autoscaling/aws ~> 9.2`, `terraform-aws-modules/s3-bucket/aws ~> 5.10`

## Conventions

- **Commits**: Conventional Commits format required. Allowed types: `fix`, `feat`, `docs`, `ci`, `chore`, `revert`. Subject must start with uppercase.
- **Releases**: Semantic Release on `master` branch, triggered by pushes to `.tf`, `.py`, `.tpl` files.
- **PR titles**: Must follow Conventional Commits (enforced by CI). Scopes: `deps`, plus Jira-style project keys.
- **Pre-commit hooks**: `terraform_fmt`, `terraform_validate`, `terraform_docs`, `terraform_tflint` (via `antonbabenko/pre-commit-terraform`).
- **Code ownership**: `@zahorniak` is default CODEOWNER.
