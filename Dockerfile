FROM gcc:6.1

WORKDIR /data

RUN wget https://alioth.debian.org/frs/download.php/file/4169/ccid-1.4.23.tar.bz2
RUN wget https://alioth.debian.org/frs/download.php/file/4164/pcsc-lite-1.8.16.tar.bz2
RUN wget https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-1.3.1.tar.gz

RUN tar -jxvf ccid-1.4.23.tar.bz2 && rm -rf ccid-1.4.23.tar.bz2 && \
  tar -jxvf pcsc-lite-1.8.16.tar.bz2 && rm -rf pcsc-lite-1.8.16.tar.bz2 && \
  tar -zxvf yubico-piv-tool-1.3.1.tar.gz && rm -rf yubico-piv-tool-1.3.1.tar.gz

RUN apt-get update && apt-get install -y apt-utils && apt-get install -y libudev-dev libusb-1.0-0-dev

RUN cd /data/pcsc-lite-1.8.16 && ./configure && make && make install
RUN cd /data/ccid-1.4.23 && ./configure && make && make install && cp src/92_pcscd_ccid.rules /etc/udev/rules.d/
RUN cd /data/yubico-piv-tool-1.3.1 && ./configure && make && make install

WORKDIR /
RUN rm -rf mv /usr/local/lib64/libstdc++.so.6.0.22-gdb.py && ldconfig

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash"]
