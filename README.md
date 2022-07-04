# ecs-fargate
Code to create vpc and deploy a sample app on ecs fargate.

# Deployment Steps

1. Execute terraform apply in vpc folder, this will create a vpc in eu-west-1 region with 10.10.0.0/16 CIDR. Get the list of private, public subnets, vpc cidr and id and update them in app.tf.
2. Update variables in app.tf for application.
3. Run deploy.sh from root of repo.

