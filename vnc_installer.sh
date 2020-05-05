sudo apt update
sudo apt install xfce4 xfce4-goodies -y
sudo apt install tightvncserver -y
vncserver
vncserver -kill :1

mv ~/.vnc/xstartup ~/.vnc/xstartup.backup_file
cat > ~/.vnc/xstartup <<EOF
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup
vncserver

apt install vim firefox -y

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb http://download.virtualbox.org/virtualbox/debian bionic contrib"

sudo apt update
sudo apt install virtualbox-6.1 -y
wget https://download.virtualbox.org/virtualbox/6.1.6/Oracle_VM_VirtualBox_Extension_Pack-6.1.6.vbox-extpack

echo " TO INSTALL EXTENTION PACK PLEASE RUN THIS COMMAND"
echo " VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack "
