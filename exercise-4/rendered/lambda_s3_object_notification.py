#!/bin/python
import boto3
ec2 = boto3.client('ssm')
a = ec2.send_command(Targets=[{"Key":"tag:Name","Values":["web-instance"]}], DocumentName='AWS-RunShellScript', Comment='abcdabcd', Parameters={"commands":["aws s3 cp s3://ry-unique-name-terraform-state-file-storage/artifacts.tar.gz /tmp/artifacts-s3.tar.gz  && rm -rf /usr/share/nginx/html/* && tar zxvf /tmp/artifacts-s3.tar.gz -C /usr/share/nginx/html/ && echo `date` >> /tmp/date.txt"]})

