vpcID=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 |  jq -r '.Vpc.VpcId'`

subnetID1=`aws ec2 create-subnet --vpc-id $vpcID --cidr-block 10.0.1.0/24 --availability-zone us-east-2a| jq -r '.Subnet.SubnetId'`
subnetID2=`aws ec2 create-subnet --vpc-id $vpcID --cidr-block 10.0.2.0/24 --availability-zone us-east-2b| jq -r '.Subnet.SubnetId'`


InternetGatewayID=`aws ec2 create-internet-gateway |  jq -r '.InternetGateway.InternetGatewayId'`



aws ec2 attach-internet-gateway --vpc-id $vpcID  --internet-gateway-id $InternetGatewayID


RoutetableID=`aws ec2 create-route-table --vpc-id $vpcID |jq -r '.RouteTable.RouteTableId'`


aws ec2 create-route --route-table-id $RoutetableID  --destination-cidr-block 0.0.0.0/0 --gateway-id $InternetGatewayID

aws ec2 describe-route-tables --route-table-id $RoutetableID

aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcID" --query 'Subnets[*].{ID:SubnetId,CIDR:CidrBlock}'


aws ec2 associate-route-table  --subnet-id $subnetID1 --route-table-id $RoutetableID
aws ec2 associate-route-table  --subnet-id $subnetID2 --route-table-id $RoutetableID


aws ec2 modify-subnet-attribute --subnet-id $subnetID1  --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $subnetID2 --map-public-ip-on-launch


aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem

chmod 400 MyKeyPair.pem

groupID=`aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id $vpcID| jq -r '.GroupId'`


aws ec2 authorize-security-group-ingress --group-id $groupID  --protocol tcp --port 22 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $groupID  --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $groupID  --protocol tcp --port 5000 --cidr 0.0.0.0/0


instanceID1=`aws ec2 run-instances --image-id ami-0dacb0c129b49f529 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids $groupID --subnet-id $subnetID1 | jq -r '.Instances[].InstanceId'`
sleep 60

publicIpAddr=`aws ec2 describe-instances --instance-ids $instanceID1 | jq -r '.Reservations[].Instances[].PublicIpAddress'`

ssh -i MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo yum update -y"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo yum -y install docker"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo service docker start"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo yum -y install nginx"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo service nginx start"



instanceID2=`aws ec2 run-instances --image-id ami-0dacb0c129b49f529 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids $groupID --subnet-id $subnetID2 | jq -r '.Instances[].InstanceId'`
sleep 60

publicIpAddr=`aws ec2 describe-instances --instance-ids $instanceID2 | jq -r '.Reservations[].Instances[].PublicIpAddress'`

ssh -i MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo yum update -y"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo yum -y install docker"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo service docker start"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo yum -y install nginx"

ssh -i  MyKeyPair.pem ec2-user@"$publicIpAddr" "sudo service nginx start"

###CREATE Load balancer 



loadbalancerarn=`aws elbv2 create-load-balancer --name my-load-balancer --subnets $subnetID1 $subnetID2 --security-groups $groupID | jq -r '.LoadBalancers[].LoadBalancerArn'`

targetgrouparn=`aws elbv2 create-target-group --name my-targets --protocol HTTP --port 5000 --vpc-id $vpcID | jq -r '.TargetGroups[].TargetGroupArn'`


 aws elbv2 register-targets --target-group-arn $targetgrouparn --targets Id=$instanceID1 Id=$instanceID2

 aws elbv2 create-listener --load-balancer-arn $loadbalancerarn --protocol HTTP --port 5000 

sleep 60

echo "Congratulations entire setup is done and ready"

echo "EC2 with webserver1:  http://$instanceID1"

echo "EC2 with webserver2:  http://$instanceID2"

echo "Load balancer url: "




