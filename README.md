# Project Overview

The first step is to deploy a pattern that will be used for updating the webservers without impacting availability. This is achieved by using GitHub Action to perform a cron job or a any update in the golden-image folder to create a new golden AMI with the latest upgrades and patches. The new ID of the AMI will be automatically stored in AWS System Manager Parameter Store which will trigger an AWS Lambda function via AWS EvenBridge every time a new image ID is updated in the parameter store which will automatically update the ASG with the newest Golden AMI using Instance Refresh later when the infrastructure is deployed. This will ensure a phased update of the webservers and will there for not impact the availability of the service. 

![This is an image](/arch/diagram.png)



At first, since Packer requires a VPC to create the Golden AMI, a temporary VPC will be created to setup packer builder EC2 instances, once the AMI is crated, AWS CLI will update the Parameter Store with the new Image ID then the temporary VPC is destroyed.
The image creation pipeline is as bellow:

![This is an image](/arch/ami-pipeline.png)

Secondly, Terraform will deploy network services such as VPC, ALB, NAT gateways, EIP, security groups webservers ASG group and VPC Endpoints. In this environment, inbound traffic will be load balanced to the webservers by the ALB which is deployed across 3 Availability Zones. An ASG will be used as the targets of the ALB. This will ensure that’s their will be autoscaling capability which will change based on CPU utilization, however the minimum amount of web servers will be 3 deployed across 3 Availability Zones to ensure maximum default availability. Outbound traffic will be routed via NAT gateway distributed across 3 Avialbility Zones. AWS Session manager, will be used instead of SSH for security purpose to log into the webservers via VPC endpoints