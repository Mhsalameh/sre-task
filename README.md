# Magento 2 + Varnish
## Usage
To start building the infrastructure we need to initiate terraform directory
```bash
terraform init
```
To apply or plan the infrastructure use the following command , but note it's better to plan and save the output , to be aware of the created infrastructure. use the following commands
```bash
terraform plan --var-file=terraform.tfvars -out=plan-file
terraform apply plan-file
```

## Variables
- **profile**               You will need an aws credentials file add the profile name to use the credentials
- **aws_region**            the aws region your infranstractures will reside in  
- **vpc_cidr_block**        IP range for you VPC
- **subnet_cidr_block1**    IP range for the first subnet
- **subnet_cidr_block2**    IP range for the second subnet
- **env**                   the environment you want to use 
- **avail_zone1**           Availability zone minimum 2 required
- **avail_zone2**           Availability zone minimum 2 required
- **ami_name**              The machine image for instances
- **instance_type**         Instance type (t2.micro for free tier)
- **private_key_file**      private_key file path to remote execute command on provisioned instances 
- **remote_user**           The remote user of the instance 

## Infrastructure
- We have 2 instances inside a VPC
- Varnish instance accepts http from loadbalancer, and ssh from anywhere
- Bastion instance accepts http from both Varnish instance and loadbalancer, also accepts ssh from anywhere
- Load balancer accepts https and http from anywhere
- Load balancer redirects http requests to https

## Notes
- Due to the shortage in resources for aws free tier, I had to allocate swap spaces in the /swap directory to provide virtual memory in the system when the physical memory is insufficient to handle the workload
- Looking at the diagram, The ssl termination was performed at the load balancer level, so I requested a certificate from ACM and used it on the load balancer
  - My other option was to use certbot on the instance level
- looking at varnish logs, the route rules are working fine for both /static and /media routes both directly routes to magento server
- for the security I would've added a bastion server to use as a jump server for the instances configuration. But currently we can ssh to the servers from anywhere using ssh keys.
 
