FROM debian:bullseye-slim

# Add hwraid repository for Bullseye
RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget \
    && wget https://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key \
    && apt-key add hwraid.le-vert.net.gpg.key \
    && echo "deb http://hwraid.le-vert.net/debian bullseye main" \
        >> /etc/apt/sources.list \
    && rm -rf hwraid.le-vert.net.gpg.key

# Install megaclisas-status
RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        megaclisas-status \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/sbin/megacli"]
CMD ["-help"]
