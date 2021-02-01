#!/bin/bash
#Quick deployment of a multi-master k3s cluster on remote machines

# ~/.ssh/config needs to contain a Host with the name k3s-master-0{1,2,3}
# passwordless sudo access recommended

ssh -t k3s-master-01 '
 sudo hostnamectl set-hostname k3s-master-01.mydomain.com
 sudo rm -f /etc/resolv.conf
 echo -e "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf > /dev/null
 export K3S_TOKEN="d0f23ad0d814bc489a00e111ec5970c7368130be963bfb4"
 export INSTALL_K3S_EXEC="server --cluster-init --secrets-encryption \
                         --tls-san=cluster.mydomain.com \
                         --node-name k3s-master-01 \
                         --disable traefik --disable servicelb --disable local-storage"

 export INSTALL_K3S_SYMLINK="skip"
 export INSTALL_K3S_CHANNEL="stable"

 #sudo curl -SsL "https://share.mydomain.com/k3s" -o /usr/local/bin/k3s #Just to bypass the slow github cdn in my area
 #sudo chmod +x /usr/local/bin/k3s

 curl -SsfL "https://get.k3s.io" | sudo --preserve-env=K3S_TOKEN --preserve-env=INSTALL_K3S_EXEC --preserve-env=INSTALL_K3S_SYMLINK --preserve-env=INSTALL_K3S_CHANNEL sh -
'

ssh -t k3s-master-02 '
 sudo hostnamectl set-hostname k3s-master-02.mydomain.com
 sudo rm -f /etc/resolv.conf
 echo -e "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf > /dev/null
 export K3S_TOKEN="d0f23ad0d814bc489a00e111ec5970c7368130be963bfb4"
 export K3S_URL="https://cluster.mydomain.com:6443"
 export INSTALL_K3S_EXEC="server --secrets-encryption \
                         --node-name k3s-master-02 \
                         --disable traefik --disable servicelb --disable local-storage"

 export INSTALL_K3S_SYMLINK="skip"
 export INSTALL_K3S_CHANNEL="stable"

 #sudo curl -SsL "https://share.mydomain.com/k3s" -o /usr/local/bin/k3s #Just to bypass the slow github cdn in my area
 #sudo chmod +x /usr/local/bin/k3s

 curl -SsfL "https://get.k3s.io" | sudo --preserve-env=K3S_TOKEN --preserve-env=K3S_URL --preserve-env=INSTALL_K3S_EXEC --preserve-env=INSTALL_K3S_SYMLINK --preserve-env=INSTALL_K3S_CHANNEL sh -
'

ssh -t k3s-master-03 '
 sudo hostnamectl set-hostname k3s-master-03.mydomain.com
 sudo rm -f /etc/resolv.conf
 echo -e "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf > /dev/null
 export K3S_TOKEN="d0f23ad0d814bc489a00e111ec5970c7368130be963bfb4"
 export K3S_URL="https://cluster.mydomain.com:6443"
 export INSTALL_K3S_EXEC="server --secrets-encryption \
                         --node-name k3s-master-02 \
                         --disable traefik --disable servicelb --disable local-storage"

 export INSTALL_K3S_SYMLINK="skip"
 export INSTALL_K3S_CHANNEL="stable"

 #sudo curl -SsL "https://share.mydomain.com/k3s" -o /usr/local/bin/k3s #Just to bypass the slow github cdn in my area
 #sudo chmod +x /usr/local/bin/k3s

 curl -SsfL "https://get.k3s.io" | sudo --preserve-env=K3S_TOKEN --preserve-env=K3S_URL --preserve-env=INSTALL_K3S_EXEC --preserve-env=INSTALL_K3S_SYMLINK --preserve-env=INSTALL_K3S_CHANNEL sh -
'
