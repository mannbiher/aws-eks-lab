Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version:  1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

#Set the proxy hostname and port
PROXY="${proxy}"
VPC_CIDR=${vpc-cidr}

#Create the docker systemd directory
mkdir -p /etc/systemd/system/docker.service.d

#Configure yum to use the proxy
cloud-init-per instance yum_proxy_config cat << EOF >> /etc/yum.conf
proxy=http://$PROXY
EOF

#Set the proxy for future processes, and use as an include file
cloud-init-per instance proxy_config cat << EOF >> /etc/environment
http_proxy=http://$PROXY
https_proxy=http://$PROXY
HTTP_PROXY=http://$PROXY
HTTPS_PROXY=http://$PROXY
no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,s3.amazonaws.com,.s3.${region}.amazonaws.com,${cluster-host}
NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,s3.amazonaws.com,.s3.${region}.amazonaws.com,${cluster-host}
EOF

#Configure docker with the proxy
cloud-init-per instance docker_proxy_config tee <<EOF /etc/systemd/system/docker.service.d/proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Configure the kubelet with the proxy
cloud-init-per instance kubelet_proxy_config tee <<EOF /etc/systemd/system/kubelet.service.d/proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Reload the daemon and restart docker to reflect proxy configuration at launch of instance
cloud-init-per instance reload_daemon systemctl daemon-reload 
cloud-init-per instance enable_docker systemctl enable --now --no-block docker

--==BOUNDARY==
Content-Type:text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace

#Set the proxy variables before running the bootstrap.sh script
set -a
source /etc/environment

--==BOUNDARY==--