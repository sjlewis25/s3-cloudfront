# S3 Static Website with CloudFront CDN

Production-grade static website infrastructure demonstrating AWS best practices for cloud support and operations.

**Live Demo**: https://d3n9dtkdnzyu4j.cloudfront.net  
**GitHub**: https://github.com/sjlewis25/s3-cloudfront

---

## Architecture
```
┌─────────────┐
│   Internet  │
│    Users    │
└──────┬──────┘
       │ HTTPS
       ↓
┌──────────────────────────────────────────────────┐
│              CloudFront CDN                       │
│  • Global Edge Locations                         │
│  • HTTPS Redirect                                │
│  • Caching (TTL: 1 hour)                        │
│  • Origin Access Identity (OAI)                 │
└──────┬──────────────────────────────────────────┘
       │ Private Access
       ↓
┌──────────────────────────────────────────────────┐
│               S3 Bucket                          │
│  • Versioning Enabled                           │
│  • AES256 Encryption                            │
│  • Public Access: BLOCKED                       │
│  • Lifecycle: Glacier after 30 days             │
└──────┬──────────────────────────────────────────┘
       │ S3 Events
       ↓
┌──────────────────────────────────────────────────┐
│          Lambda File Validator                   │
│  • Validates file types on upload               │
│  • Checks file size limits                      │
│  • Sends alerts for violations                  │
└──────┬──────────────────────────────────────────┘
       │ Publish
       ↓
┌──────────────────────────────────────────────────┐
│            SNS Topic → Email                     │
│  • File validation alerts                       │
│  • CloudWatch alarm notifications               │
└──────────────────────────────────────────────────┘

       ┌──────────────────────────────────────────┐
       │        CloudWatch Alarms                 │
       │  • 4xx Error Rate > 5%                  │
       │  • 5xx Error Rate > 1%                  │
       │  • S3 Bucket Size > 1GB                 │
       └──────────────────────────────────────────┘
```

---

## Key Features

| Feature | Implementation | Benefit |
|---------|---------------|---------|
| **Global CDN** | CloudFront with edge locations | Low latency worldwide |
| **Security** | OAI + blocked public access | S3 not directly accessible |
| **Encryption** | AES256 at rest | Data protection |
| **Versioning** | S3 versioning enabled | Recovery from accidental changes |
| **Cost Optimization** | Lifecycle policies to Glacier | 30-day transition saves costs |
| **Monitoring** | CloudWatch alarms + SNS | Proactive issue detection |
| **Automation** | Lambda validation | Prevents unauthorized uploads |
| **IaC** | Modular Terraform | Repeatable, version-controlled |

---

## Technologies

- **Infrastructure**: Terraform (modular architecture)
- **AWS Services**: S3, CloudFront, Lambda, CloudWatch, SNS, IAM
- **Languages**: Python (Lambda), HCL (Terraform)
- **CI/CD**: Git-based workflow

---

## Deployment
```bash
# Clone repository
git clone https://github.com/sjlewis25/s3-cloudfront.git
cd s3-cloudfront

# Configure Terraform variables
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your bucket name and email

# Deploy infrastructure
terraform init
terraform plan
terraform apply

# Upload website files
cd ../../..
aws s3 sync website/ s3://YOUR-BUCKET-NAME/

# Get CloudFront URL
terraform output -raw website_url
```

---

## Troubleshooting Guide

### Common Issue #1: 403 Forbidden Error

**Symptom**: Users receive 403 error when accessing the site

**Root Causes**:
1. Bucket policy doesn't allow CloudFront OAI
2. Public access block is preventing CloudFront
3. Object doesn't exist in S3

**How to Debug**:
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket YOUR-BUCKET-NAME

# Verify OAI has access
aws cloudfront get-cloud-front-origin-access-identity --id YOUR-OAI-ID

# Check if file exists
aws s3 ls s3://YOUR-BUCKET-NAME/

# Check CloudWatch logs for access patterns
aws logs tail /aws/cloudfront/YOUR-DISTRIBUTION --follow
```

**Solution**: Verify bucket policy includes CloudFront OAI ARN with `s3:GetObject` permission

---

### Common Issue #2: Slow Page Load Times

**Symptom**: Website loads slowly despite CloudFront

**Root Causes**:
1. Cache hit ratio is low
2. Origin response time is high
3. Large uncached objects

**How to Debug**:
```bash
# Check CloudFront cache statistics
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name CacheHitRate \
  --dimensions Name=DistributionId,Value=YOUR-DIST-ID \
  --start-time 2024-12-27T00:00:00Z \
  --end-time 2024-12-28T00:00:00Z \
  --period 3600 \
  --statistics Average

# Check origin response time
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name OriginLatency \
  --dimensions Name=DistributionId,Value=YOUR-DIST-ID \
  --start-time 2024-12-27T00:00:00Z \
  --end-time 2024-12-28T00:00:00Z \
  --period 3600 \
  --statistics Average
```

**Solutions**:
- Increase TTL for static assets
- Enable compression in CloudFront
- Optimize object sizes
- Review cache behaviors

---

### Common Issue #3: Lambda Validation Not Triggering

**Symptom**: Files upload but no validation alerts received

**Root Causes**:
1. S3 event notification not configured
2. Lambda execution role lacks permissions
3. SNS topic subscription not confirmed

**How to Debug**:
```bash
# Check S3 event notifications
aws s3api get-bucket-notification-configuration --bucket YOUR-BUCKET-NAME

# Check Lambda logs
aws logs tail /aws/lambda/s3-file-validator-dev --follow

# Test Lambda manually
aws lambda invoke \
  --function-name s3-file-validator-dev \
  --payload file://test-event.json \
  response.json

# Check SNS subscriptions
aws sns list-subscriptions-by-topic --topic-arn YOUR-TOPIC-ARN
```

**Solution**: Confirm SNS email subscription and verify Lambda has `s3:GetObject` and `sns:Publish` permissions

---

## Monitoring & Alerts

**CloudWatch Alarms**:
- **4xx Error Rate**: Triggers when > 5% (2 consecutive periods)
- **5xx Error Rate**: Triggers when > 1% (1 period)
- **S3 Bucket Size**: Triggers when > 1GB

**SNS Notifications**:
- Alarm state changes sent to configured email
- Lambda validation failures
- File type violations

**View Metrics**:
```bash
# CloudFront metrics
aws cloudwatch list-metrics --namespace AWS/CloudFront

# S3 metrics  
aws cloudwatch list-metrics --namespace AWS/S3

# Lambda metrics
aws cloudwatch list-metrics --namespace AWS/Lambda
```

---

## Cost Analysis

**Monthly Cost Estimate**: $1-5

| Service | Usage | Cost |
|---------|-------|------|
| S3 Storage | 1GB | $0.023 |
| S3 Requests | 10k GET | $0.004 |
| CloudFront | 10GB transfer | $0.85 |
| Lambda | 1k invocations | Free tier |
| CloudWatch | 3 alarms | Free tier |

**Cost Optimization Strategies**:
1. Lifecycle policies (Glacier after 30 days) - saves 80% on old versions
2. PriceClass_100 (US, Canada, Europe only) - cheaper than global
3. Incomplete upload cleanup - prevents wasted storage
4. CloudFront compression - reduces bandwidth costs

---

## Skills Demonstrated

**For Cloud Support Engineer Roles**:
- S3 bucket policies and IAM troubleshooting
- CloudFront CDN configuration and caching strategies
- Lambda event-driven architecture
- CloudWatch monitoring, metrics, and alarms
- Cost optimization through lifecycle management
- Security best practices (OAI, encryption, least-privilege IAM)

**Infrastructure as Code**:
- Modular Terraform architecture
- Resource dependencies and outputs
- Variable management across environments
- State management

---

## Security Features

1. **Origin Access Identity (OAI)**: CloudFront-only access to S3
2. **Blocked Public Access**: All four S3 public access settings enabled
3. **AES256 Encryption**: Server-side encryption at rest
4. **HTTPS Redirect**: All HTTP requests redirected to HTTPS
5. **IAM Least Privilege**: Lambda has minimal required permissions
6. **Versioning**: Protection against accidental deletion

---

## Future Enhancements

- Custom domain with Route 53 + ACM certificate
- AWS WAF for additional security (SQL injection, XSS protection)
- S3 access logging and analysis with Athena
- Cost tracking dashboard with detailed breakdowns
- CI/CD pipeline for automated deployments
- Blue/green deployment strategy
- CloudFront Functions for edge computing

---

## License

MIT License - Feel free to use this as a template for your own projects

---

## Author

**Steve Lewis**  
Cloud Engineer | AWS Solutions Architect Associate | Marine Corps Veteran

- GitHub: [@sjlewis25](https://github.com/sjlewis25)
- Portfolio: [Live Demo](https://d3n9dtkdnzyu4j.cloudfront.net)
