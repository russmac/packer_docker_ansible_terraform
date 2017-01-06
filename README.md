#DEPRECATED

Untested in over 8 months

## A project used to learn packer docker ansible and terraform.
Deploys a wordpress container in AWS ECS.


### Use

Grab a stable release from "Releases" (they are all tested working)

Requires you setup AWS Elastic Container Registry yourself first.
You will then need to get your 24 hour ecr token and repoistory address from AWS ECR (using awscli) using this command.

aws ecr get-login

Then replace the existing ecr address and token in wordpress_template.json

Make sure to change your passwords and account specific parameters in:
 variables.tf 
 wordpress_template.json
 task-definitions/dockerfile.json
 wordpress-nginx/group_vars/all 

```
packer build wordpress_template.json
```

```
terraform apply
```

### Bugs

Terraform:

* Terraform apparently only allows one policy per role , Deleting role resource causes recreation with still only 1 policy.
 
Ansible:

* Ansible mysqldb fails as $HOME for root in docker instance is / (ansible default .my.cnf is ~) setting env var in task def resolves
Setting HOME to /root however does not resolve (except for mysql client) and login_username and login_password -must- be used.

* Randomly errors out while rendering templates happens 1/10 runs during initial provisioning. I've seen sporadic bug reports mentioning it.

### Further improvements

* Deploying arbritrary apps instead of wordpress, Or something specific like rails apps. Would probably need to use capistrano somewhere.

* Switching to Debian (systemd), The anisble playbook I grabbed wanted CentOS however if this was a production deployment I would use Debian.

* Running a custom ecs-agent ecs-server using Debian.

* Using an nginx container and a php-fpm container with a linked socket

* Using Cloudwatch, SNS and Lambda to autoscale the ECS service using ELB connection metrics.
  
* Hardening Wordpress such as disabling xmlrpc.php

* Configuring forced ssl rewrites for /wp-admin path utilising ELB for terminating SSL and removing cpu overhead from containers.

* Tweaking container resource assignments
