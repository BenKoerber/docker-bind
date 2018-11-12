# Get base OS
FROM alpine:3.8

# Update and install bind
RUN apk --update add bind

# Copy image files to container
COPY image/etc/bind/* /config/image/etc/bind/

# Bind need both protocols tcp and udp on port 53
EXPOSE 53/udp
EXPOSE 53/tcp

# Entrypoint
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT ["/sbin/entrypoint.sh"]

# Default command
CMD ["/usr/sbin/named"]

# Maintainer
LABEL maintainer="Ben Koerber <ben.koerber@gmail.com>"

