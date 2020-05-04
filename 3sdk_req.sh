mkdir -p ~/sandbox/code/github/threefoldtech/
cd ~/sandbox/code/github/threefoldtech/
git clone -b development https://github.com/threefoldtech/jumpscaleX_core/
cd jumpscaleX_core/install
apt update
apt install python3-pip -y
pip3 install --user -e .


apt-get remove docker docker-engine docker.io containerd runc
apt-get install  -y   apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
