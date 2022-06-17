FROM quay.io/fedora/fedora:36-x86_64

LABEL name="webhook-proxy" \
      maintainer="xiaofwan@redhat.com" \
      vendor="Red Hat QE Section 1" \
      version="1.1" \
      release="1" \
      summary="webhook proxy server" \
      description="A proxy server to fetch AWS SQS message repeatly" \
      io.k8s.description="A proxy server to fetch AWS SQS message repeatly" \
      io.k8s.display-name="webhook proxy" \
      io.openshift.tags="webhook-proxy,webhook,proxy"

ENV PROXY_ROOT=/home/proxy

USER root

RUN dnf -y update && \
    dnf -y install \
        net-tools \
        procps-ng \
        curl \
        gcc \
        python3 \
        python3-devel \
        python3-pip && \
    dnf clean all && \
    pip install boto3 requests && \
    mkdir -p ${PROXY_ROOT} && \
    chmod -R g=u ${PROXY_ROOT} /etc/passwd /etc/group && \
    chgrp -R 0 ${PROXY_ROOT}

COPY proxy.py entrypoint.sh /home/proxy/
RUN chmod 755 ${PROXY_ROOT}/{proxy.py,entrypoint.sh}

WORKDIR ${PROXY_ROOT}

USER 1001

ENTRYPOINT ["/home/proxy/entrypoint.sh"]
CMD ["python3", "-u","/home/proxy/proxy.py"]
