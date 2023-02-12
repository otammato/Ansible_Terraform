# Ansible_Terraform (the page is under development)
[ IaC, Configuration, Automation, Ansible, Terraform ]

In this demo:
<br>

1. We will use Terraform to deploy a template that sets up a virtual private cloud (VPC) with two subnets: a public subnet and a private subnet. <br>
The private subnet will host a single "master" server with Ansible already installed, while the public subnet will host three "slave" servers. Additionally, two security groups will be established to provide secure access, with SSH access granted to the master and both SSH and HTTP access granted to the slaves for hosting a simple website. The Terraform template will also provide the public IP addresses of the slave servers as outputs and save them in the "inventory" file. 
<br>

2. We will use Ansible to automate the deployment of the website on the three slave servers, utilizing a playbook and an inventory file.


<br><br>
### Technologies:
1. Terraform<br>
2. Ansible

<br><br>

![image](https://user-images.githubusercontent.com/104728608/217630228-d582ae23-1690-44cf-8a6e-5a6c2155c341.png)

<br><br>


### 0. Start your IDE
<br><br>

### 1. Download and launch a Terraform template from here:<br>
https://github.com/otammato/Ansible_Terraform/tree/main/Terraform
<br>

Download:
<br>
```
mkdir Terraform && cd Terraform/
wget https://raw.githubusercontent.com/otammato/Ansible_Terraform/main/Terraform/infra.tf
```

Make sure you replace the key_name parameter in the template with yours, navigate to the Terraform folder, and then launch a Terraform template
<br>
```
$ terraform init
$ terraform validate
$ terrraform plan
$ terraform apply
```

### 2. Note the outputs after the infrastructure created - private ip addresses of slaves - they are saved to "inventory" file similar to this: <br>
<br>

```
172.31.98.102
172.31.99.103
172.31.99.104
```
### 3. Create your key file in .ssh folder (just copy the content of RSA key in a file with the same name and .pem type) and use rsync to copy the created by Terraform file "inventory", from a local machine to a remote master<br>
<br>

```
chmod 400 $HOME/.ssh/test_delete.pem

rsync -Pav -e "ssh -i $HOME/.ssh/test_delete.pem" /home/ec2-user/environment/Terraform ec2-user@ip-172-31-99-203:~ 
```

### 4. Alternatively, SSH to your master instance, create an "inventory" file, paste the Terraform output of slaves' IPs and save the file
<br>

```
touch inventory
vi inventory
```

### 5. When you SSH connected to your Master Instance, download the Ansible playbook from here: https://github.com/otammato/Ansible_Terraform/blob/main/Ansible/install_site_playbook.yml
<br>

```
wget https://raw.githubusercontent.com/otammato/Ansible_Terraform/main/Ansible/install_site_playbook.yml
```

<br><br>
### 6. Copy your public key (in my case it is test_delete.pem) to the master server and place it in home/ec2-user/.ssh, also assign this rights:
<br><br>

```
chmod 400 ~/.ssh/test_delete.pem 
```


### 7. Ping your slave EC2 instances from a master EC2:
<br>

```
ansible all --key-file ~/.ssh/test_delete.pem -i inventory -m ping -u ec2-user
```

<br><br>
<p align="center" >
  <img width="700" alt="Screenshot 2023-02-12 at 15 42 32" src="https://user-images.githubusercontent.com/104728608/218321078-8b124ae4-4337-406c-afb0-903a63aa4a70.png">
</p>
<br><br>


### 8. Create ansible.cfg file and specify the location of your rsa key
<br>

```
[defaults]
remote_user = ec2-user 
inventory = inventory 
private_key_file = ~/.ssh/test_delete.pem
```


### 8. Run the ansible playbook "install_site_playbook.yml"

```
ansible-playbook install_site_playbook.yml
```

<br><br>
<p align="center" >
  <img width="700" alt="Screenshot 2023-02-12 at 15 59 09" src="https://user-images.githubusercontent.com/104728608/218321928-9942497e-651a-4b08-af26-e312fa587b50.png">
</p>
<br><br>

### 9. Test the website was sucessfully launched by using public IPs of slave instances: 

<br><br>
<p align="center" >
  <img width="700" alt="Screenshot 2023-02-12 at 16 18 20" src="https://user-images.githubusercontent.com/104728608/218323036-54f3dca5-ce55-45cd-91fc-135f9ab688f4.png">
</p>
<br><br>


<br><br>
some more info you might need if you decide not to use terraform or AWS Cloud9 ide:

```
1. create key pairs on the ansible-machine 
    ssh-keygen -t rsa -b 2048

2. import public key into the ec2 console
    aws ec2 import-key-pair --key-name "test_delete" --public-key-material fileb://~/.ssh/test_delete.pem

3. install ansible on ansible-machine
    sudo yum update -y
    sudo amazon-linux-extras install ansible2 -y
```

