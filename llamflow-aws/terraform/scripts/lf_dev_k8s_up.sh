#!/bin/bash
sudo snap install microk8s --classic --channel 1.30/stable


sudo usermod -a -G microk8s ubuntu
mkdir -p ~/.kube
chmod 0700 ~/.kube

sudo apt update
sudo snap install aws-cli --classic


# microk8s add-node --format short
