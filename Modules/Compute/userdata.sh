#!/bin/bash

dnf update -y
dnf install nginx -y

systemctl enable nginx
systemctl start nginx

# Fetch IMDSv2 token first, then use it to get the AZ
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Production Build Challenge</title>
    <style>
    body{
        font-family:Arial,sans-serif;
        background:#0f172a;
        color:white;
        text-align:center;
        padding-top:100px;
    }
    .card{
        width:700px;
        margin:auto;
        padding:40px;
        border-radius:15px;
        background:#1e293b;
    }
    </style>
</head>
<body>
<div class="card">
    <h1> Production Build Challenge Completed</h1>
    <h2>Deployment Successful</h2>
    <p>NGINX is running successfully on AWS EC2.</p>
    <p><strong>Availability Zone:</strong> $AZ</p>
    <p><strong>Status:</strong> Healthy ✅</p>
    <p>Thank you for reviewing this solution.</p>
</div>
</body>
</html>
EOF

systemctl restart nginx

dnf install amazon-cloudwatch-agent -y

################################################
# Configure CloudWatch Agent
################################################

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/${project_name}/${environment}/nginx/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/${project_name}/${environment}/nginx/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

################################################
# Start CloudWatch Agent
################################################

systemctl enable amazon-cloudwatch-agent

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
-s