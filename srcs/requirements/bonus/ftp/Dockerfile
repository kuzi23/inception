FROM alpine:3.20

RUN apk update && apk add --no-cache vsftpd

ARG FTP_USER
ARG FTP_PASSWORD

# Create FTP User
RUN adduser -D $FTP_USER && echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Configure vsftpd
RUN echo "local_enable=YES" >> /etc/vsftpd/vsftpd.conf \
    && echo "write_enable=YES" >> /etc/vsftpd/vsftpd.conf \
    && echo "local_umask=022" >> /etc/vsftpd/vsftpd.conf \
    && echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf \
    && echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf \
    && echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf \
    && echo "pasv_min_port=21100" >> /etc/vsftpd/vsftpd.conf \
    && echo "pasv_max_port=21100" >> /etc/vsftpd/vsftpd.conf \
    && echo "seccomp_sandbox=NO" >> /etc/vsftpd/vsftpd.conf

# Ensure volume mount point owner
RUN mkdir -p /var/www/html && chown $FTP_USER:$FTP_USER /var/www/html
RUN sed -i "s|/home/$FTP_USER|/var/www/html|g" /etc/passwd

EXPOSE 20 21 21100

CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]
