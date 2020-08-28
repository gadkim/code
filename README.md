<1> Terraform code
- Terraform_main.tf
  1) VPC
  2) Subnet
  3) Internet Gateway
  4) EIP
  5) NAT Gateway
  6) Route Table
  7) Route Table Attached
  8) Security Group
  9) EC2
  10) EC2 Volume
  11) Transit Gateway
  12) Transit Gateway Connection
  13) Route Table Transit Gateway Connection
  
Reference URL : https://computingforgeeks.com/how-to-install-terraform-on-ubuntu-centos-7/

Terraform moule : https://registry.terraform.io/providers/hashicorp/aws/latest/docs

<1> Install Terraform on Ubuntu
  1) Terraform Directory Create\n
    # mkdir /terraform
    # cd /terraform
    
  2) Terraform Download
    # wget  https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip

  3) Terraform Unzip
    # unzip terraform_0.12.24_linux_amd64.zip
    
  4) Move exe file
    # mv terraform /usr/local/bin
    
  5) Terraform Version
    # terraform -v
    
  6) Terraform main.tf config
    # vim main.tf
    <main.tf code Reference>
    
  7) Terraform Directory reset
    # terraform init
    
  8) terraform validate
    # terraform validate
    
  9) terraform config apply
    # terraform apply
    
  10 terraform aws resouce delete
    # terraform destroy
    
    
