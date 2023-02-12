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

### 2. Note the outputs after the infrastructure created - ip addresses of slaves - they are saved to "inventory" file similar to this: <br>
<br>

```
172.31.98.102
172.31.99.103
172.31.99.104
```
### 3. Create your key file in .ssh folder (just copy the content of RSA key in a file with the same name and .pem type) and use rsync to copy the created by Terraform file "inventory", needed to Ansible later, from a local machine to a remote master<br>
<br>

```
chmod 400 $HOME/.ssh/test_delete.pem

rsync -Pav -e "ssh -i $HOME/.ssh/test_delete.pem" /home/ec2-user/environment/Terraform ec2-user@ip-172-31-99-203:~ 
```

### 4. Alternatively, SSH to your master instance, create "inventory" file, paste the Terraform output for slaves' IPs and save the file
<br>

```
touch inventory
vi inventory
```

### 5. When you SSH connected to your Master Instance, download Ansible playbook from here: https://github.com/otammato/Ansible_Terraform/blob/main/Ansible/install_site_playbook.yml
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








1. create the ansible machine sg
    - ssh from ip

2. create the server sg 
    ssh from ansible sg
    http from port 80

3. launch the ansible-machine 
    amazon linux 2

4. create key pairs on the ansible-machine 
    ssh-keygen -t rsa -b 2048

5. import public key into the ec2 console
    ansible-pub-key

6. launch the servers
    key pair: ansible-pub-key
    sg: server-sg 

7. test connection 
    ssh private ip

8. install ansible on ansible-machine
    sudo yum update -y
    sudo amazon-linux-extras install ansible2 -y

9. create inventory file

10. create playbook

11. ansible all --key-file ~/.ssh/id_rsa -i inventory -m ping -u ec2-user

12. create an ansible.cfg file 
[defaults]
remote_user = ec2-user 
inventory = inventory 
private_key_file = ~/.ssh/id_rsa

13. run the ansible playbook
    ansible-playbook deploy-techmax.yml

14
