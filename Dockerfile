FROM ubuntu:24.04

# Filename of the .deb in this folder (set WATCHTOWER_DEB in .env)
ARG WATCHTOWER_DEB
ENV DEBIAN_FRONTEND=noninteractive

# The .deb is self-contained; Recommends (Mesa/GL libs) are pulled in for
# thumbnail recolors. systemd is absent, so postinst skips unit setup, but it
# still creates the unprivileged "watchtower" user and /var/lib/watchtower.
COPY ${WATCHTOWER_DEB} /tmp/watchtower.deb
RUN apt-get update \
 && apt-get install -y --no-install-recommends adduser ca-certificates tzdata /tmp/watchtower.deb \
      libegl1 libegl-mesa0 libgl1-mesa-dri libopengl0 libglu1-mesa \
 && rm -rf /tmp/watchtower.deb /var/lib/apt/lists/*

ENV HOME=/var/lib/watchtower \
    LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    WATCHTOWER_RAMDISK_PATH=/run/watchtower

# Remap the service user to the host's appdata owner (set PUID/PGID in .env)
# so bind-mounted appdata is writable without a manual chown. systemd normally
# provides /run/watchtower (RuntimeDirectory=), so create it here.
ARG PUID
ARG PGID
RUN test -n "$PUID" && test -n "$PGID" \
 && (getent group "$PGID" >/dev/null || groupmod -g "$PGID" watchtower) \
 && usermod -u "$PUID" -g "$PGID" watchtower \
 && mkdir -p /run/watchtower \
 && chown -R "$PUID:$PGID" /var/lib/watchtower /run/watchtower \
 && chmod 0750 /run/watchtower

USER watchtower
WORKDIR /opt/watchtower
VOLUME /var/lib/watchtower
STOPSIGNAL SIGTERM
CMD ["/opt/watchtower/start_watchtower"]
