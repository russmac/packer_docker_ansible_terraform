#!/bin/bash
rm /etc/localtime && ln -s /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
yum -y update
yum -y install htop vim iotop
mkdir /etc/ecs
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config