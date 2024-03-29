# Ansible_Terraform 
[ IaC, Configuration, Automation, Ansible, Terraform ]

In this demo:
<br>

1. We will use Terraform to deploy a template that sets up a virtual private cloud (VPC) with two subnets: a public subnet and a private subnet. <br>
The private subnet will host a single "master" server with Ansible already installed, while the public subnet will host three "slave" servers. Additionally, two security groups will be established to provide secure access, with SSH access granted to the master and both SSH and HTTP access granted to the slaves for hosting a simple website. The Terraform template will also provide the public IP addresses of the slave servers as outputs and save them in the "inventory" file. 
<br>

2. We will use Ansible to automate a deployment of a website on three slave servers, utilizing a playbook and an inventory file.


<br><br>
### Technologies:
1. Terraform<br>
2. Ansible


<br><br>
<p align="center" >
  <img width="700" alt="Screenshot 2023-02-12 at 20 13 42" src="https://user-images.githubusercontent.com/104728608/218334773-842bf460-1675-4d09-bf94-c507975f49e0.png">
</p>
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
$ terraform apply -auto-approve
```
<br><br>
<p align="center" >
  <img width="700" alt="Screenshot 2023-02-12 at 17 36 59" src="https://user-images.githubusercontent.com/104728608/218327408-e9ca510c-8269-462e-b3a1-5b1a59682028.png">
</p>
<br><br>

### 2. Note the outputs after the infrastructure is created - private ip addresses of slaves - they are also automatically saved to an "inventory" file similar to this: <br>
<br>

```
172.31.98.201
172.31.99.231
172.31.99.138
```
### 3. Create your key file in .ssh folder (just copy the content of RSA key in a file with the same name and .pem type) and use rsync to copy the created by Terraform file "inventory", from a local machine to a remote master<br>
<br>

```
chmod 400 $HOME/.ssh/test_delete.pem

rsync -Pav -e "ssh -i $HOME/.ssh/test_delete.pem" /home/ec2-user/environment/Terraform ec2-user@ip-172-31-99-203:/home/ec2-user
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
### 6. Copy your public key (in my case it is test_delete.pem) to the master server and place it in home/ec2-user/.ssh, also assign these rights:
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
  <img width="700" alt="Screenshot 2023-02-12 at 16 40 05" src="https://user-images.githubusercontent.com/104728608/218324285-6a842f39-0aad-46cd-a688-66b8ff7fc7c3.png">
</p>
<br><br>

### 8. Get info about OS of your slaves' EC2 instances:

```
ansible linux -a "cat etc/os-release"
```

### 9. Create an ansible.cfg file and specify the location of your rsa key
<br>

```
[defaults]
remote_user = ec2-user 
inventory = inventory 
private_key_file = ~/.ssh/test_delete.pem
```

### 10. Run the ansible playbook "install_site_playbook.yml"

```
ansible-playbook install_site_playbook.yml
```

<br><br>
<p align="center" >
  <img width="700" alt="Screenshot 2023-02-12 at 16 43 12" src="https://user-images.githubusercontent.com/104728608/218324429-d9b3dce7-1d57-42a0-a764-563f9a9bc1a8.png">
</p>
<br><br>


### 11. Test the website was sucessfully launched by using public IPs of the slave instances: 

<br><br>
<p align="center" >
  <img width="700" alt="Screenshot 2023-02-12 at 16 18 20" src="https://user-images.githubusercontent.com/104728608/218323036-54f3dca5-ce55-45cd-91fc-135f9ab688f4.png">
</p>
<br><br>


### 12. Clean up

```
exit #this is to exit from your master EC2 instance and switch to your local machine or, in my case, to the EC2 where Cloud9 was launched

terraform destroy -auto-approve
```
<p align="center" >
  <img width="607" alt="Screenshot 2023-02-12 at 17 12 46" src="https://user-images.githubusercontent.com/104728608/218325985-a551cd71-94cb-4d6a-aed8-ddb4b42ab580.png">
</p>
<br><br>

<br><br>
some more info you might need if you decide not to use Terraform or AWS Cloud9 IDE:

```
1. create key pairs on a master machine 
    ssh-keygen -t rsa -b 2048

2. import public key into the ec2 console
    aws ec2 import-key-pair --key-name "test_delete" --public-key-material fileb://~/.ssh/test_delete.pem

3. install ansible on a master machine
    sudo yum update -y
    sudo amazon-linux-extras install ansible2 -y
```

