#!/bin/bash

set -e

export HOME=/home/vscode
export USER=vscode
export DISPLAY=:1

VNC_DIR="$HOME/.config/tigervnc"
VNC_PORT=5901
NOVNC_PORT=6080

echo "=== Starting Linux Desktop ==="

mkdir -p "$VNC_DIR"

# =========================================================
# VNC PASSWORD
# =========================================================

if [ ! -f "$VNC_DIR/passwd" ]; then
    echo "Creating VNC password..."
    echo "codespace" | tigervncpasswd -f > "$VNC_DIR/passwd"
    chmod 600 "$VNC_DIR/passwd"
fi

# =========================================================
# XFCE STARTUP
# =========================================================

cat > "$VNC_DIR/xstartup" <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_CURRENT_DESKTOP=XFCE

exec dbus-launch --exit-with-session startxfce4
EOF

chmod +x "$VNC_DIR/xstartup"

# =========================================================
# STOP OLD VNC
# =========================================================

echo "Stopping old VNC..."

vncserver -kill :1 2>/dev/null || true

rm -f /tmp/.X1-lock
rm -f /tmp/.X11-unix/X1

# =========================================================
# START VNC
# =========================================================

echo "Starting TigerVNC..."

vncserver :1 \
    -geometry 1920x1080 \
    -depth 24 \
    -localhost no

sleep 2

# =========================================================
# CHECK VNC
# =========================================================

if ! ss -lnt | grep -q ":$VNC_PORT "; then
    echo "ERROR: VNC is not listening on port $VNC_PORT"
    exit 1
fi

echo "VNC is running on port $VNC_PORT"

# =========================================================
# STOP OLD NOVNC
# =========================================================

echo "Stopping old noVNC..."

pkill -f "websockify.*$NOVNC_PORT" 2>/dev/null || true

sleep 1

# =========================================================
# START NOVNC
# =========================================================

echo "Starting noVNC..."

nohup websockify \
    --web=/usr/share/novnc \
    0.0.0.0:$NOVNC_PORT \
    127.0.0.1:$VNC_PORT \
    > /tmp/novnc.log 2>&1 &

sleep 2

# =========================================================
# CHECK NOVNC
# =========================================================

if ! ss -lnt | grep -q ":$NOVNC_PORT "; then
    echo "ERROR: noVNC is not listening on port $NOVNC_PORT"
    cat /tmp/novnc.log
    exit 1
fi

echo "noVNC is running on port $NOVNC_PORT"

echo ""
echo "=========================================="
echo " Linux Desktop is ready!"
echo "=========================================="
echo ""
echo "Open:"
echo "http://localhost:$NOVNC_PORT/vnc.html"
echo ""
