#!/bin/sh
#!/bin/bash
#swsh 
#author :: amit213, amit tank
#revision history / summary.


tmpFilePath="tmpFiles"
sshDir=".ssh"
sshKeyName="testKeysforVM"

cd
cd devstack
source openrc admin admin

#creat basic tmpbox flavors
nova flavor-create m1.tmpbox auto 512 4 1
nova flavor-create m1.tmpbox2 auto 1024 10 1

rm -rf $tmpFilePath 
mkdir $tmpFilePath
cd $tmpFilePath

wget http://uec-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
glance image-create --name "trustyUbun" --disk-format qcow2 --file ./trusty-server-cloudimg-amd64-disk1.img --container-format bare --is-public True

mkdir ~/$sshDir
cd ~/$sshDir
ssh-keygen -t rsa -f $sshKeyName -N ""
nova keypair-add --pub-key ~/$sshDir/$sshKeyName.pub $sshKeyName
neutron subnet-update  --dns-nameserver 8.8.8.8 private-subnet --dns-nameserver 8.8.4.4

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#neutron security-group-rule-create --protocol icmp --direction ingress default
#neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress default

cd
cd ~/devstack
#nova boot --image trustyUbun --flavor m1.tmpbox --key-name $sshKeyName  worker10


