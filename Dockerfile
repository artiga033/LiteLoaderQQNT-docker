FROM debian:bookworm

RUN apt-get update &&\
    apt-get install --no-install-recommends --no-install-suggests -y \
    icewm novnc x11vnc xvfb xterm locales curl unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG zh_CN.UTF-8  
ENV LC_ALL zh_CN.UTF-8 

RUN curl -Lo /tmp/websockify-rs.zip $( \
    curl 'https://api.github.com/repos/artiga033/websockify-rs/releases/latest' | \
    sed -rn 's/^.*browser_download_url.*(https:.*x86_64-unknown-linux-musl\.zip).*$/\1/p' \
    ) && \
    unzip /tmp/websockify-rs.zip websockify-rs -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/websockify-rs && \
    rm /tmp/websockify-rs.zip

RUN curl -Lo /tmp/ntqq.deb $( \
    curl 'https://cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/linuxQQDownload.js' | \
    sed 's/,/,\n/g' | \
    sed -rn 's/^.*x64DownloadUrl.*(https:.*.deb).*$/\1/p' \
    ) && \
    apt-get update && apt-get install -y /tmp/ntqq.deb && \
    # required for qq
    apt-get install -y libasound2 fonts-noto-cjk libgbm1 &&\ 
    rm /tmp/ntqq.deb && \
    rm -rf /var/lib/apt/lists/*
VOLUME [ "/root/.config/QQ" ]

ENV LITELOADERQQNT_PROFILE=/var/LiteLoaderQQNT
RUN curl -Lo /tmp/LiteLoaderQQNT.zip $( \
    curl 'https://api.github.com/repos/LiteLoaderQQNT/LiteLoaderQQNT/releases/latest' | \
    sed -rn 's/^.*browser_download_url.*(https:.*LiteLoaderQQNT\.zip).*$/\1/p' \
    ) && \
    unzip /tmp/LiteLoaderQQNT.zip -d /opt/QQ/resources/app/LiteLoader && \
    sed -i '1s/^/require("\/opt\/QQ\/resources\/app\/LiteLoader");\n/' /opt/QQ/resources/app/app_launcher/index.js && \
    rm /tmp/LiteLoaderQQNT.zip && \
    mkdir -p ${LITELOADERQQNT_PROFILE}
VOLUME ${LITELOADERQQNT_PROFILE}

ENV DISPLAY=:0
EXPOSE 80
WORKDIR /XVNC

COPY entrypoint.sh /XVNC/entrypoint.sh

CMD ["bash","/XVNC/entrypoint.sh"]