FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN dnf install -y \
  util-linux \
  e2fsprogs \
  xfsprogs \
  findutils \
  && dnf clean all

COPY init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]
