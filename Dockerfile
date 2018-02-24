FROM fedora:27

RUN dnf install -y \
      bash \
      fio \
      git \
      maven \
      strace \
    && dnf clean all

COPY run_bench.sh /

CMD /run_bench.sh
