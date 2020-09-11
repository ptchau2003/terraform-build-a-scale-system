# The instruction to build an AWS scaling system using Terrform (on default VPC)
### The system includes:
* #####  Application Load Balancer: HTTPS, HTTP will be redirected to HTTPS, the TLS certificate is local one (can be replaced with the one in ACM)
* #####  Auto-scaling group: Min=1, Max=4, EC2 with scale metric: CPU 60% and NetworkInput 600Mbytes/s, Immutable deployment
* #####  Launch configuration EC2: t3.micro, 20G standard disk mount point /dev/sda1, user_data with nginx_install.sh will install NGINX, keypair: ec2-key, private key saved on your local machine directory

 ### Generating the local X509 key and put it into IAM (it is for HTTPS) 
 ###### Generate RSA key:
   *openssl genrsa 2048 > privatekey.pem*
 ###### Generate CSR key:
   *openssl req -new -key privatekey.pem -out csr.pem* 
 ###### Generate CRT key:
   *openssl x509 -req -days 365 -in csr.pem -signkey privatekey.pem -out public.crt*

### Put the certificate into IAM:
 *aws iam upload-server-certificate --server-certificate-name application-loadbalacer-x509 --certificate-body file://public.crt --private-key file://privatekey.pem*
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
### Input the AWS key, prepare for the AWS deployment
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
var.certificate_arn
  The local certificate ARN was get from previous step
  Enter a value: arn:aws:iam::XXXXXXXXXXXXXXX:server-certificate/application-loadbalacer-x509

var.privatekey_directory
  The directory of RSA private key created: /home/<user>/.ssh/id_rsa
  Enter a value: /home/cloud_user/.ssh/id_rsa
```
An execution plan has been generated and is shown below.

Plan: 12 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_key_pair.ec2-key: Creating...
aws_default_vpc.default: Creating...
aws_key_pair.ec2-key: Creation complete after 1s [id=ec2-key]
aws_default_vpc.default: Creation complete after 5s [id=vpc-036ae5d3b549574df]
data.aws_subnet_ids.default: Reading...
aws_lb_target_group.auto-target-group: Creating...
aws_security_group.loadbalance-sg: Creating...
data.aws_subnet_ids.default: Read complete after 0s [id=vpc-036ae5d3b549574df]
aws_lb_target_group.auto-target-group: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:targetgroup/test/dbb9f9a501c3520f]
aws_security_group.loadbalance-sg: Creation complete after 3s [id=sg-094c05bbc3237cfe3]
aws_lb.application-load-balancer: Creating...
aws_security_group.ec2-sg: Creating...
aws_security_group.ec2-sg: Creation complete after 4s [id=sg-0ec0472230091f0d9]
aws_launch_template.launch-configuration-template: Creating...
aws_launch_template.launch-configuration-template: Creation complete after 1s [id=lt-06ed2ee8955e99295]
aws_autoscaling_group.auto-scaling-group: Creating...
aws_lb.application-load-balancer: Still creating... [10s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [10s elapsed]
aws_lb.application-load-balancer: Still creating... [20s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [20s elapsed]
aws_lb.application-load-balancer: Still creating... [30s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [30s elapsed]
aws_lb.application-load-balancer: Still creating... [40s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [40s elapsed]
aws_lb.application-load-balancer: Still creating... [50s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [50s elapsed]
aws_lb.application-load-balancer: Still creating... [1m0s elapsed]
aws_autoscaling_group.auto-scaling-group: Still creating... [1m0s elapsed]
aws_autoscaling_group.auto-scaling-group: Creation complete after 1m5s [id=test]
aws_autoscaling_policy.auto-scaling-policy-CPU: Creating...
aws_autoscaling_policy.auto-scaling-policy-BW: Creating...
aws_lb.application-load-balancer: Still creating... [1m10s elapsed]
aws_autoscaling_policy.auto-scaling-policy-BW: Creation complete after 1s [id=BW]
aws_autoscaling_policy.auto-scaling-policy-CPU: Creation complete after 2s [id=CPU]
aws_lb.application-load-balancer: Still creating... [1m20s elapsed]
aws_lb.application-load-balancer: Still creating... [1m30s elapsed]
aws_lb.application-load-balancer: Still creating... [1m40s elapsed]
aws_lb.application-load-balancer: Still creating... [1m50s elapsed]
aws_lb.application-load-balancer: Still creating... [2m0s elapsed]
aws_lb.application-load-balancer: Still creating... [2m10s elapsed]
aws_lb.application-load-balancer: Still creating... [2m20s elapsed]
aws_lb.application-load-balancer: Still creating... [2m30s elapsed]
aws_lb.application-load-balancer: Still creating... [2m40s elapsed]
aws_lb.application-load-balancer: Still creating... [2m50s elapsed]
aws_lb.application-load-balancer: Still creating... [3m0s elapsed]
aws_lb.application-load-balancer: Still creating... [3m10s elapsed]
aws_lb.application-load-balancer: Still creating... [3m20s elapsed]
aws_lb.application-load-balancer: Still creating... [3m30s elapsed]
aws_lb.application-load-balancer: Provisioning with 'local-exec'...
aws_lb.application-load-balancer (local-exec): Executing: ["/bin/sh" "-c" "echo test-1067508475.us-east-1.elb.amazonaws.com"]
aws_lb.application-load-balancer (local-exec): test-1067508475.us-east-1.elb.amazonaws.com
aws_lb.application-load-balancer: Creation complete after 3m39s [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:loadbalancer/app/test/caf88c77828da862]
aws_lb_listener.application-listener-http: Creating...
aws_lb_listener.application-listener-https: Creating...
aws_lb_listener.application-listener-http: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:listener/app/test/caf88c77828da862/4c63fa94ea0751f9]
aws_lb_listener.application-listener-https: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:listener/app/test/caf88c77828da862/cf425829d803e25b]

Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
```
### Terraform destroy
terraform destroy
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_autoscaling_policy.auto-scaling-policy-CPU: Destroying... [id=CPU]
aws_lb_listener.application-listener-http: Destroying... [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:listener/app/test/68b4faaea78a0521/a7191ca120a6ddf6]
aws_autoscaling_policy.auto-scaling-policy-BW: Destroying... [id=BW]
aws_lb_listener.application-listener-https: Destroying... [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:listener/app/test/68b4faaea78a0521/231501e417913f83]
aws_lb_listener.application-listener-https: Destruction complete after 1s
aws_lb_listener.application-listener-http: Destruction complete after 1s
aws_lb.application-load-balancer: Destroying... [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:loadbalancer/app/test/68b4faaea78a0521]
aws_autoscaling_policy.auto-scaling-policy-CPU: Destruction complete after 1s
aws_autoscaling_policy.auto-scaling-policy-BW: Destruction complete after 1s
aws_autoscaling_group.auto-scaling-group: Destroying... [id=test]
aws_lb.application-load-balancer: Destruction complete after 2s
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 10s elapsed]
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 20s elapsed]
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 30s elapsed]
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 40s elapsed]
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 50s elapsed]
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 1m0s elapsed]
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 1m10s elapsed]
aws_autoscaling_group.auto-scaling-group: Still destroying... [id=test, 1m20s elapsed]
aws_autoscaling_group.auto-scaling-group: Destruction complete after 1m29s
aws_launch_template.launch-configuration-template: Destroying... [id=lt-05673344896f828ad]
aws_lb_target_group.auto-target-group: Destroying... [id=arn:aws:elasticloadbalancing:us-east-1:461184534637:targetgroup/test/ee53559f2226cc9c]
aws_lb_target_group.auto-target-group: Destruction complete after 1s
aws_launch_template.launch-configuration-template: Destruction complete after 1s
aws_key_pair.ec2-key: Destroying... [id=ec2-key]
aws_security_group.ec2-sg: Destroying... [id=sg-0209fd71c808ba5b9]
aws_key_pair.ec2-key: Destruction complete after 0s
aws_security_group.ec2-sg: Destruction complete after 1s
aws_security_group.loadbalance-sg: Destroying... [id=sg-0a1629f7396a09d95]
aws_security_group.loadbalance-sg: Destruction complete after 1s
aws_default_vpc.default: Destroying... [id=vpc-036ae5d3b549574df]
aws_default_vpc.default: Destruction complete after 0s

Destroy complete! Resources: 12 destroyed.
```
