# The instruction to build an AWS scaling system using Terrform (on default VPC)
### The system includes:
* #####  Application Load Balancer: HTTPS, HTTP will be redirected to HTTPS, the TLS certificate is local one (can be replaced with the one in ACM)
* #####  Auto-scaling group: Min=1, Max=4, EC2 with scale metric: CPU 60% and NetworkInput 600Mbytes/s
* #####  Launch configuration EC2: t3.micro, 20G standard disk mount point /dev/sda1, user_data with nginx_install.sh will install NGINX, keypair: ec2-key, private key saved on your local machine directory

 ### Generating the local X509 key and put it into IAM (it is for HTTPS) 
 ###### Generate RSA key:
   *openssl genrsa 2048 > privatekey.pem*
 ###### Generate CSR key:
   *openssl req -new -key privatekey.pem -out csr.pem* 
 ###### Generate CRT key:
   *openssl x509 -req -days 365 -in csr.pem -signkey privatekey.pem -out public.crt*

### Put the certificate into IAM:
 *aws iam upload-server-certificate --server-certificate-name elastic-beanstalk-x509 --certificate-body file://public.crt --private-key file://privatekey.pem*
```json
 { 
    "ServerCertificateMetadata": { 
        "Path": "/",
        "ServerCertificateName": "elastic-beanstalk-x509", 
         "ServerCertificateId": "XXXXXXXXXXXXXXXXXXX", 
         "Arn": "arn:aws:iam::XXXXXXXXXXXXXX:server-certificate/elastic-beanstalk-x509", 
         "UploadDate": "2020-08-31T11:38:47+00:00", 
         "Expiration": "2021-08-31T08:33:36+00:00" 
     } 
 }
 ```
### Input the AWS key, prepare for the AWS deploy
aws configure
```
AWS Access Key ID [****************XUOH]: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
AWS Secret Access Key [****************EQSD]: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [us-east-1]:
Default output format [json]:
```
### Terraform init
terraform init
```
Initializing the backend...

Initializing provider plugins...
- Using previously-installed hashicorp/aws v3.6.0

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, we recommend adding version constraints in a required_providers block
in your configuration, with the constraint strings suggested below.

* hashicorp/aws: version = "~> 3.6.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
### Terraform validate
terraform validate
```
Success! The configuration is valid.
```
### Deploy the scaling system
terrafrom apply
```
Plan: 12 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: **yes**
aws_key_pair.ec2-key: Creating...
aws_default_vpc.default: Creating...
aws_key_pair.ec2-key: Creation complete after 0s [id=ec2-key]
aws_default_vpc.default: Creation complete after 4s [id=vpc-036ae5d3b549574df]
data.aws_subnet_ids.default: Reading...
aws_lb_target_group.auto-target-group: Creating...
aws_security_group.loadbalance-sg: Creating...
data.aws_subnet_ids.default: Read complete after 1s [id=vpc-036ae5d3b549574df]
aws_lb_target_group.auto-target-group: Creation complete after 2s [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:targetgroup/test/ee53559f2226cc9c]
aws_security_group.loadbalance-sg: Creation complete after 4s [id=sg-0a1629f7396a09d95]
aws_lb.application-load-balancer: Creating...
aws_security_group.ec2-sg: Creating...
aws_security_group.ec2-sg: Creation complete after 3s [id=sg-0209fd71c808ba5b9]
aws_launch_template.launch-configuration-template: Creating...
aws_launch_template.launch-configuration-template: Creation complete after 1s [id=lt-05673344896f828ad]
aws_autoscaling_group.auto-scaling-group: Creating...
aws_lb.application-load-balancer: Still creating... [10s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [10s elapsed]
aws_lb.application-load-balancer: Still creating... [20s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [20s elapsed]
aws_lb.application-load-balancer: Still creating... [30s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [30s elapsed]
aws_lb.application-load-balancer: Still creating... [40s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [40s elapsed]
aws_autoscaling_group.auto-scaling-group: Creation complete after 43s [id=test]
aws_autoscaling_policy.auto-scaling-policy-BW: Creating...
aws_autoscaling_policy.auto-scaling-policy-CPU: Creating...
aws_autoscaling_policy.auto-scaling-policy-BW: Creation complete after 2s [id=BW]
aws_autoscaling_policy.auto-scaling-policy-CPU: Creation complete after 2s [id=CPU]
aws_lb.application-load-balancer: Still creating... [50s elapsed]
aws_lb.application-load-balancer: Still creating... [1m0s elapsed]
aws_lb.application-load-balancer: Still creating... [1m10s elapsed]
```
