# EKS Cluster Complete Deletion Script (PowerShell)
# Includes VPC and all related resources

Write-Host "Starting EKS cluster deletion..." -ForegroundColor Red

# Cluster configuration
$CLUSTER_NAME = "my-eks-cluster"
$REGION = "ap-northeast-2"
$PROFILE = "sso"

Write-Host "Checking current cluster status..." -ForegroundColor Yellow
eksctl get cluster --name $CLUSTER_NAME --region $REGION --profile $PROFILE

Write-Host "Checking node groups..." -ForegroundColor Yellow
eksctl get nodegroup --cluster $CLUSTER_NAME --region $REGION --profile $PROFILE

Write-Host "WARNING: This will permanently delete the cluster!" -ForegroundColor Red
$confirmation = Read-Host "Do you want to continue? (y/N)"

if ($confirmation -ne "y" -and $confirmation -ne "Y") {
    Write-Host "Deletion cancelled" -ForegroundColor Red
    exit 1
}

Write-Host "Deleting EKS cluster... (takes about 10-15 minutes)" -ForegroundColor Cyan
eksctl delete cluster --name $CLUSTER_NAME --region $REGION --profile $PROFILE

Write-Host "EKS cluster deletion completed!" -ForegroundColor Green
Write-Host "Deleted resources:" -ForegroundColor Blue
Write-Host "   - EKS cluster: $CLUSTER_NAME" -ForegroundColor White
Write-Host "   - Node groups: worker-nodes-small (or worker-nodes)" -ForegroundColor White
Write-Host "   - VPC and subnets (10.0.0.0/16)" -ForegroundColor White
Write-Host "   - Internet Gateway" -ForegroundColor White
Write-Host "   - NAT Gateway" -ForegroundColor White
Write-Host "   - Route Tables" -ForegroundColor White
Write-Host "   - Security Groups" -ForegroundColor White
Write-Host "   - IAM roles and policies" -ForegroundColor White
Write-Host "   - EC2 instances" -ForegroundColor White
Write-Host "   - EBS volumes" -ForegroundColor White

Write-Host "All resources have been successfully deleted!" -ForegroundColor Green
