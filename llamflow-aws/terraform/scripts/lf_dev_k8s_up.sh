#!/bin/bash
sudo snap install microk8s --classic --channel 1.30/stable


sudo usermod -a -G microk8s ubuntu
mkdir -p ~/.kube
chmod 0700 ~/.kube

sudo apt update
sudo snap install aws-cli --classic

count=0
while `microk8s kubectl get node | grep -q "NotReady"` && [ $count -lt 11 ]
do
  echo "Waiting for kube to become ready"
  sleep 3
  ((count++))
done
  
instanceId=`ec2metadata --instance-id`
aws lambda invoke --function-name microk8s_new_node --invocation-type Event --payload "{\"new_node\" : \"$instanceId\"}" --cli-binary-format raw-in-base64-out  /dev/stdout