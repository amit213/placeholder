#!/bin/sh
#!/bin/bash
#swsh 
#author :: amit213, amit tank
#revision history / summary.


tmpFilePath="tmpFiles"
sshDir=".ssh"
sshKeyName="id_rsa"
devstackDir="devstack"

create_keypair_files() {
  mkdir ~/$sshDir
  cd ~/$sshDir
  ssh-keygen -t rsa -f $sshKeyName -N ""
}

run_common_housekeeping() {
  nova keypair-add --pub-key ~/$sshDir/$sshKeyName.pub $sshKeyName	
}

add_images_to_glance() {

  #wget http://uec-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
  #glance image-create --name "trustyUbun" --disk-format qcow2 --file ./trusty-server-cloudimg-amd64-disk1.img --container-format bare --is-public True
  glance image-create --name "trustyUbun" --disk-format qcow2 --copy-from http://uec-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img --container-format bare --is-public True --property hw_watchdog_action=reset

  glance image-create --name "centOS7genericCloudx86_64" --disk-format qcow2 --container-format bare --is-public true --copy-from http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-20140929_01.qcow2 --property hw_watchdog_action=reset

  #cd /tmp/
  wget http://stable.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2
  bunzip2 coreos_production_openstack_image.img.bz2
  glance image-create --name "coreOS" --container-format bare --disk-format qcow2 --file ./coreos_production_openstack_image.img --is-public True --property hw_watchdog_action=reset
  glance image-create --name "fedora21cloud" --disk-format qcow2 --container-format bare --is-public true --copy-from http://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Base-20141203-21.x86_64.qcow2 --property hw_watchdog_action=reset
  glance image-create --name "centOS7" --disk-format qcow2 --container-format bare --is-public true --copy-from http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-20140929_01.qcow2 --property hw_watchdog_action=reset
}

add_rules_to_secgroup() {
  sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  neutron security-group-rule-create --protocol icmp --direction ingress default
  neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress default
}

create_subnet_config() {
  neutron subnet-update  --dns-nameserver 8.8.8.8 private-subnet --dns-nameserver 8.8.4.4
}

add_custom_falvors() {
  #create basic tmpbox flavors
  nova flavor-create m1.tmpbox auto 512 8 1
  nova flavor-create m1.tmpbox2 auto 1024 12 1 
}

cd
cd devstack
source openrc admin admin

add_custom_falvors

rm -rf $tmpFilePath 
mkdir $tmpFilePath
cd $tmpFilePath


#add images to glance
add_images_to_glance

create_keypair_files

run_common_housekeeping

source ~/$devstackDir/openrc demo demo

run_common_housekeeping

create_subnet_config

add_rules_to_secgroup

cd
cd ~/$devstackDir
#nova boot --image trustyUbun --flavor m1.tmpbox --key-name $sshKeyName  worker10


