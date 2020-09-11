# The instruction to build an AWS scaling system using Terrform (on default VPC)
### The system includes:
* #####  Application Load Balancer: HTTPS, HTTP will be redirected to HTTPS
* #####  Auto-scaling group: Min=1, Max=4, EC2 with scale metric: CPU 60% and NetworkInput 600Mbytes/s
* #####  Target Group
* #####  Launch configuration EC2: t3.micro, 10G general disk mount on /dev/sda1 

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
```
aws configure
AWS Access Key ID [****************XUOH]: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
AWS Secret Access Key [****************EQSD]: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [us-east-1]:
Default output format [json]:
```
### Terraform init
```
terraform init

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
```
terraform validate
Success! The configuration is valid.
```
### Deploy the scaling system
terrafrom apply

