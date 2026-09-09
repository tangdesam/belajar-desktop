FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/vscode/.config/tigervnc \
    && chown -R vscode:vscode /home/vscode/.config

COPY start-desktop.sh /usr/local/bin/start-desktop.sh

RUN chmod +x /usr/local/bin/start-desktop.sh \
    && chown vscode:vscode /usr/local/bin/start-desktop.sh

EXPOSE 6080
