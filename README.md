README



1. Created the Python based application which is running on port 5000 and giving the hostname
 
Python code file is in getHost.py (attached)
Context Root of application is /hostname

2. Containerize the Python application by created custom image, commands are as follows

   docker build -t gethost 
   docker run -t -i -d -p 5000:5000 gethost

Dockerfile code is in Dockerfile (attached)


AWS console access user created with Administration access

AccountID: 675747301766
username: touchbistro
password: SREAssignment123


So this solved the application code and its containerization requirement

Please note: CentralInstance Ec2 instance is used for all code creation and testing.

##############Section 2#######################

########Deployment Option 2######################

### All below could be validated from AWS console as well############

1. Deploy the app on EC2 instance with Docker 

Done on couple of instance with name PythonDocker 

URL are: http://3.137.190.46:5000/hostname/

        http://18.221.103.173:5000/hostname/


2. Use a LAYER7 reverse proxy load balancer

Created ELB Application Load Balancer which is doing the load balancing and the load balancer url is
 
http://pythonweb-914421767.us-east-2.elb.amazonaws.com/hostname/

Target group name is: pythonwebtg

3. Load balance across multiple instance -- As its doing the load balancing across multiple instance

4. Entire IaaC code is written using AWS CLI wrapped inside shell script

 -- README for createInfra (attached)
 -- Code for creating entire Infra is in creatInfra.sh (attached)

5. Usage of ansible for the EC2 setup

Written dockerplaybook.yaml which should be triggered for creating the image and launch the container. 
Please note: Docker is already installed through the IaaC

Code is written in dockerplaybook.yaml (attached)

Usage:  Run the playbook using ansible-playbook -i <inventoryfile> dockerplaybook.yaml 

Please note: We will ned PEM file to connect to instances, MyKeyPair.pem (attached)

#################################################################################

#############Section 3###################################

#########Bonus###############

1. Application is dynamically scaled as created the AMI, launch configuration and Autoscalegroup with user based configuration

AMI name is: WebPythonHostnameAMI

Launch configuration: WebPythonDockerContainer

Auto Scale group is: WebPythonDockerASG

As of now it is one instance as desired capacity.

Upon scaling its added automatically inside the ELB target group directly and load balancing is happening on the same.

Load Balancer url is doing load balancing across EC2 instance through Auto scaling group as well

Load balancer url: http://pythonweb-914421767.us-east-2.elb.amazonaws.com/hostname/

Ec2 instance under Autoscale group are named as: ScaledPythonDocker


2. Public name and DNS is used and the url is 

http://pythonweb-914421767.us-east-2.elb.amazonaws.com/hostname/




