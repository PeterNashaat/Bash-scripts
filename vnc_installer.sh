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
