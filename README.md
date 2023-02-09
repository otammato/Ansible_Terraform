# Ansible_Terraform (the page is under development)
[ IaC, Configuration, Ansible, Terraform ]

In this demo:
1. We will utilize Terraform to deploy a template that sets up a virtual private cloud (VPC) with two subnets: a public subnet and a private subnet. The private subnet will host a single "master" server with Ansible already installed, while the public subnet will host three "slave" servers. Additionally, two security groups will be established to provide secure access, with SSH access granted to the master and both SSH and HTTP access granted to the slaves for hosting a simple website. The Terraform template will also provide the public IP addresses of the slave servers as outputs. 
2. Finally, we will use Ansible to automate the deployment of the website on the three slave servers, utilizing a playbook and an inventory file.


<br><br>
### Technologies:
1. Terraform<br>
2. Ansible

<br><br>

![image](https://user-images.githubusercontent.com/104728608/217630228-d582ae23-1690-44cf-8a6e-5a6c2155c341.png)

<br><br>


### 1. 


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

12. create ansible.cfg file 
[defaults]
remote_user = ec2-user 
inventory = inventory 
private_key_file = ~/.ssh/id_rsa

13. run the ansible playbook
    ansible-playbook deploy-techmax.yml

14
