import imp
import json
import boto3
import logging
import os
from pprint import pprint

def lambda_handler(event, context):

    #ec2_client = boto3.client('ec2')
    asg_client = boto3.client('autoscaling')
    #region = os.environ['AWS_REGION']
    ssm = boto3.client('ssm')
    ec2_client = boto3.client('ec2')

    parameter_name = "/amis/linux/golden-ami"
    asg_name = "webserver-asg"

    #####################################################
    # Get The New AMI ID
    response = ssm.get_parameters(Names=[parameter_name])
    for x in response['Parameters']:
        ami=(x['Value'])

    #print(ami)
    #####################################################
    # Get Launch Template ID
    asg = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])
    asg_details = asg['AutoScalingGroups'][0]
    template_id = asg_details['LaunchTemplate']['LaunchTemplateId']

    # print(template_id)
    # print(ami)

    ####################################################
    #Create New Launch Template
    launch_templates = ec2_client.describe_launch_templates(LaunchTemplateIds=[template_id,])
    latest_version = launch_templates['LaunchTemplates'][0]['LatestVersionNumber']

    #print(latest_version)
    response = ec2_client.create_launch_template_version(


        LaunchTemplateName='webserver_launch_template',
        SourceVersion = str(latest_version),
        LaunchTemplateData= {
            'ImageId': ami
        }
    )

    new_version = response['LaunchTemplateVersion']['VersionNumber']
    #print(new_version)

    ####################################################
    # Start Autoscaling Instance Refresh

    response = asg_client.start_instance_refresh(
        AutoScalingGroupName=asg_name,
        Strategy='Rolling',
        Preferences={
            'MinHealthyPercentage': 50,
            'InstanceWarmup': 400
                        })


