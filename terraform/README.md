# CURE Terraform Infrastructure

This Terraform project provisions the AWS infrastructure for the CURE Cloud & DevOps Engineering assessment.

## Resources

- VPC with public/private subnets
- EKS cluster
- EKS managed node group
- RDS PostgreSQL in private subnets
- Private encrypted S3 bucket
- IRSA role for backend S3 access
- AWS Load Balancer Controller
- Optional Prometheus/Grafana monitoring

## Secrets

Do not commit real secrets.

Pass secrets at apply time:

```powershell
terraform apply `
  -var="db_master_password=YOUR_DB_PASSWORD"
```

The DB password is marked sensitive and ephemeral. JWT management is handled separately when creating the Kubernetes secret.

## Apply

```powershell
terraform init
terraform plan `
  -var="db_master_password=YOUR_DB_PASSWORD"

terraform apply `
  -var="db_master_password=YOUR_DB_PASSWORD"
```

## After apply

Update kubeconfig:

```powershell
terraform output -raw kubectl_update_kubeconfig_command
```

Get RDS endpoint:

```powershell
$RDS_ENDPOINT = terraform output -raw rds_endpoint
```

Build DATABASE_URL manually using the same DB password passed to Terraform:

```powershell
$DATABASE_URL = "postgresql+psycopg2://cure_app:YOUR_DB_PASSWORD@$RDS_ENDPOINT:5432/cure_db"
```

Create Kubernetes Secret manually:

```powershell
kubectl create namespace cure --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic cure-backend-secret `
  -n cure `
  --from-literal=DATABASE_URL="$DATABASE_URL" `
  --from-literal=JWT_SECRET="YOUR_JWT_SECRET"
```

Then apply Kubernetes manifests:

```powershell
kubectl apply -k ../k8s
```

## Destroy

```powershell
terraform destroy `
  -var="db_master_password=YOUR_DB_PASSWORD"
```


# One honest warning

This is production-shaped, but a fully polished enterprise version would also add:

- Remote encrypted Terraform backend in S3 + DynamoDB lock
- Official least-privilege ALB controller IAM policy JSON
- Route53 hosted zone and ACM DNS validation
- External Secrets Operator
- CloudWatch log retention controls
- KMS CMK for RDS/S3 instead of AWS-managed keys
- VPC endpoints for S3/ECR/CloudWatch/STS/Secrets Manager

For your internship assessment and demo, the above Terraform is a strong modular baseline and enough to show serious DevOps/cloud engineering depth.
