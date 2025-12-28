# S3 Static Website with CloudFront CDN

Production-grade static website infrastructure demonstrating AWS best practices for cloud support and operations.

**Live Demo**: https://d3n9dtkdnzyu4j.cloudfront.net

## Architecture
```
User → CloudFront CDN → S3 Bucket
                ↓
            Lambda Validator → SNS Alerts
                ↓
         CloudWatch Alarms
```

## Features

- **S3 Static Hosting**: Versioning enabled with lifecycle policies (30-day Glacier transition)
- **CloudFront CDN**: Global content delivery with HTTPS redirect and caching optimization  
- **Automated Validation**: Lambda function validates file types and sizes on upload
- **Monitoring & Alerts**: CloudWatch alarms for 4xx/5xx errors and storage limits
- **Security**: Origin Access Identity (OAI), AES256 encryption, blocked public access
- **Cost Optimization**: PriceClass_100, lifecycle policies, incomplete upload cleanup

## Technologies

- **Terraform**: Modular infrastructure-as-code
- **AWS Services**: S3, CloudFront, Lambda, CloudWatch, SNS, IAM
- **Python**: Lambda function for file validation

## Project Structure
```
├── terraform/
│   ├── modules/
│   │   ├── s3/              # S3 bucket configuration
│   │   ├── cloudfront/      # CDN distribution
│   │   ├── lambda/          # File validation
│   │   └── monitoring/      # CloudWatch alarms
│   └── environments/
│       └── dev/             # Development environment
├── lambda/
│   └── functions/           # Lambda function code
└── website/                 # Static website files
```

## Deployment
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply

# Upload website files
aws s3 sync ../../../website/ s3://YOUR-BUCKET-NAME/
```

## Skills Demonstrated

**Cloud Support Engineering:**
- S3 bucket policies and permissions troubleshooting
- CloudFront distribution configuration and caching
- Lambda event-driven architecture
- CloudWatch monitoring and alerting
- Cost optimization strategies

**Infrastructure as Code:**
- Modular Terraform design
- AWS provider configuration
- Resource dependencies and outputs

**Security:**
- IAM least-privilege policies
- S3 encryption at rest (AES256)
- Blocking public access
- Origin Access Identity (OAI)

## Common Troubleshooting Scenarios

This project addresses real-world support scenarios:

1. **403 Forbidden Errors**: Bucket policy misconfiguration with OAI
2. **Slow Load Times**: CloudFront cache settings optimization
3. **File Upload Failures**: Lambda validation with SNS alerts
4. **Cost Spikes**: Lifecycle policy monitoring and Glacier transitions
5. **CORS Issues**: CloudFront behavior configuration

## Monitoring

CloudWatch alarms trigger SNS notifications for:
- 4xx error rate > 5%
- 5xx error rate > 1%  
- Bucket size > 1GB

## Cost Estimate

Monthly cost: **~$1-5** (mostly CloudFront requests)
- S3: $0.023/GB storage
- CloudFront: $0.085/GB data transfer (first 10TB)
- Lambda: Free tier eligible (1M requests/month)

## License

MIT
