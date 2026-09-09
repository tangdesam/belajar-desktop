#!/bin/bash

set -e

export DISPLAY=:1

# Bersihkan session lama
vncserver -kill :1 2>/dev/null || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# Konfigurasi VNC
mkdir -p /home/vscode/.vnc

cat > /home/vscode/.vnc/xstartup <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_CURRENT_DESKTOP=XFCE
export XDG_CONFIG_DIRS=/etc/xdg/xdg-xfce:/etc/xdg/xdg-xubuntu:/etc/xdg

startxfce4 &
EOF

chmod +x /home/vscode/.vnc/xstartup
chown -R vscode:vscode /home/vscode/.vnc

# Password VNC
echo "codespace" | vncpasswd -f > /home/vscode/.vnc/passwd
chmod 600 /home/vscode/.vnc/passwd
chown vscode:vscode /home/vscode/.vnc/passwd

# Jalankan VNC
sudo -u vscode vncserver :1 \
    -geometry 1920x1080 \
    -depth 24 \
    -localhost no

# Jalankan noVNC
websockify \
    --web=/usr/share/novnc \
    6080 \
    localhost:5901
