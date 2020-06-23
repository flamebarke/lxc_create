#!/bin/bash

# Install required dependencies
sudo apt install -y lxc libvirt-bin libvirt-clients libvirt-daemon-system \
iptables ebtables dnsmasq-base libxml2-utils iproute2

# Create config
sudo mv /etc/lxc/default.conf /etc/lxc/default.conf.bak
sudo echo '
# Network configuration
lxc.net.0.type = veth
lxc.net.0.link = virbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx

# Default apparmor config
lxc.apparmor.profile = generated
lxc.apparmor.allow_nesting = 1

# Autostart on Boot
# lxc.start.auto = 1
' > /etc/lxc/default.conf

# Create bridge (host may need to be restarted)
sudo virsh net-start default
sudo virsh net-autostart default
sudo ifconfig virbr0

echo '
[*] Use the following commands to create an alpine container:
[host] sudo lxc-create -t download -n alpine
[host] sudo lxc-ls
[host] sudo lxc-info -n alpine
[host] sudo lxc-start -n alpine
[host] sudo lxc-attach -n alpine
[alpine] useradd alpine -s /bin/ash
[alpine] apk add openssh
[alpine] rc-update add sshd
[alpine] rc-status
[alpine] /etc/init.d/sshd start
[host] sudo lxc-console -n alpine

[!] Refer below for further config:

https://wiki.debian.org/LXC
https://linuxcontainers.org/lxc/manpages/man5/lxc.container.conf.5.html
'
