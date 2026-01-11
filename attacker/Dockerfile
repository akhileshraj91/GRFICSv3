FROM kalilinux/kali-rolling:latest

# Build args / defaults
ARG DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV NOVNC_PORT=6080
ENV VNC_PORT=5900
ENV VNC_PASSWORD=changeme
ENV RESOLUTION=1280x720
ENV USERNAME=kali
ENV HOME=/home/$USERNAME

# Install essentials
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      kali-desktop-xfce dbus-x11 \
      x11vnc xvfb xauth x11-utils \
      wget git nano python3 python3-pip python3-websockify \
      ca-certificates supervisor sudo \
      net-tools procps pulseaudio-utils dsniff \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN useradd -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME}:kali" | chpasswd && \
    usermod -aG sudo ${USERNAME}

# Install noVNC (from GitHub) and websockify (pip installed websockify already available)
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify || true && \
    chmod -R a+rx /opt/noVNC

# Create directories for runtime files
RUN mkdir -p /var/run/xvfb /var/run/x11vnc /opt/novnc/utils && chown -R ${USERNAME}:${USERNAME} ${HOME}


# Install tools
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    kali-tools-top10 python3-pymodbus

# Supervisor config (to run xvfb, x11vnc, websockify)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY default.xml /etc/xdg/xfce4/panel/default.xml

COPY index.html /opt/noVNC/index.html


# Entrypoint script that sets password and starts the desktop session
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# allow passwordless sudo
RUN echo "kali ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/kali \
 && chmod 440 /etc/sudoers.d/kali

RUN sed -i 's/^#*autologin-user=.*/autologin-user=kali/' /etc/lightdm/lightdm.conf || true \
 && sed -i 's/^#*autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf || true

RUN mkdir -p /home/kali/.config/autostart \
 && cp /etc/xdg/autostart/xfce4-power-manager.desktop /home/kali/.config/autostart/ \
 && sed -i 's/^Exec=/#Exec=/' /home/kali/.config/autostart/xfce4-power-manager.desktop \
 && echo 'Hidden=true' >> /home/kali/.config/autostart/xfce4-power-manager.desktop \
 && chown -R kali:kali /home/kali/.config


RUN mv /usr/bin/xflock4 /usr/bin/xflock4.real && \
    printf '#!/bin/sh\nexit 0\n' > /usr/bin/xflock4 && \
    chmod +x /usr/bin/xflock4


COPY xfce-no-lock.sh /usr/local/bin/xfce-no-lock.sh
RUN chmod +x /usr/local/bin/xfce-no-lock.sh


EXPOSE ${NOVNC_PORT} ${VNC_PORT}

USER root

ENTRYPOINT ["/usr/local/bin/start.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]