# The instruction to build an AWS scaling system using Terrform (on default VPC)
#### The system includes:
##### 1. Application Load Balancer
##### 2. Auto-scaling group
##### 3. Target Group
##### 4. Launch configuration
##### 5. EC2

* Generating the local X509 key and put it into IAM (it is for HTTPS) 
 Generate RSA key: 
 ** openssl genrsa 2048 > privatekey.pem ** 
 Generate CSR key: 
 ** openssl req -new -key privatekey.pem -out csr.pem **
 Generate CRT key: 
 ** openssl x509 -req -days 365 -in csr.pem -signkey privatekey.pem -out public.crt **

* Put into IAM:
> aws iam upload-server-certificate --server-certificate-name elastic-beanstalk-x509 --certificate-body file://public.crt --private-key file://privatekey.pem
> {
>    "ServerCertificateMetadata": {
>        "Path": "/",
>        "ServerCertificateName": "elastic-beanstalk-x509",
>         "ServerCertificateId": "XXXXXXXXXXXXXXXXXXX",
>         "Arn": "arn:aws:iam::XXXXXXXXXXXXXX:server-certificate/elastic-beanstalk-x509",
>         "UploadDate": "2020-08-31T11:38:47+00:00",
>         "Expiration": "2021-08-31T08:33:36+00:00"
>     }
> }
