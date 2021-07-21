FROM kalilinux/kali-rolling

RUN apt-get update -y && \
    apt-get install openvpn iputils-ping -y

ARG CONFIG_FILE

COPY ${CONFIG_FILE} /home/config.ovpn

# ENTRYPOINT [ "cat", "/home/config.ovpn" ]

ENTRYPOINT ["openvpn", "/home/config.ovpn"]