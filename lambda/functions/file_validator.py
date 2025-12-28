import json
import boto3
import os
from datetime import datetime

s3 = boto3.client('s3')
sns = boto3.client('sns')

ALLOWED_EXTENSIONS = ['.html', '.css', '.js', '.jpg', '.jpeg', '.png', '.gif', '.ico', '.svg']
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

def lambda_handler(event, context):
    """
    Validates uploaded files and sends alerts for violations
    """
    
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        size = record['s3']['object']['size']
        
        print(f"Processing: {key} ({size} bytes)")
        
        # Check file extension
        file_ext = os.path.splitext(key)[1].lower()
        if file_ext not in ALLOWED_EXTENSIONS:
            alert_message = f"ALERT: Unauthorized file type uploaded\n"
            alert_message += f"File: {key}\n"
            alert_message += f"Extension: {file_ext}\n"
            alert_message += f"Bucket: {bucket}\n"
            alert_message += f"Time: {datetime.now().isoformat()}"
            
            send_alert(alert_message)
            print(f"Alert sent for unauthorized file: {key}")
            return {
                'statusCode': 400,
                'body': json.dumps('Unauthorized file type')
            }
        
        # Check file size
        if size > MAX_FILE_SIZE:
            alert_message = f"ALERT: File size exceeds limit\n"
            alert_message += f"File: {key}\n"
            alert_message += f"Size: {size / (1024*1024):.2f}MB\n"
            alert_message += f"Limit: {MAX_FILE_SIZE / (1024*1024)}MB\n"
            alert_message += f"Bucket: {bucket}"
            
            send_alert(alert_message)
            print(f"Alert sent for oversized file: {key}")
        
        # File is valid
        print(f"File validated successfully: {key}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Files validated successfully')
    }

def send_alert(message):
    """Send SNS alert"""
    topic_arn = os.environ.get('SNS_TOPIC_ARN')
    if topic_arn:
        try:
            sns.publish(
                TopicArn=topic_arn,
                Subject='S3 File Validation Alert',
                Message=message
            )
        except Exception as e:
            print(f"Error sending SNS notification: {str(e)}")
