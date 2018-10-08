FROM ubuntu:18.04 AS build
LABEL maintainer "Shuanglei Tao - tsl0922@gmail.com"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      cmake \
      curl \
      g++ \
      git \
      libjson-c3 \
      libjson-c-dev \
      libssl1.0.0 \
      libssl-dev \
      libwebsockets8 \
      libwebsockets-dev \
      pkg-config \
      vim-common \ 
      apt-transport-https \
      software-properties-common \
      gpg-agent \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends yarn \
    && git clone --depth=1 https://github.com/cicavey/ttyd.git /tmp/ttyd \
    && cd /tmp/ttyd/html && yarn && yarn run build && rm -rf node_modules /usr/local/share/.cache \
    && cd /tmp/ttyd && mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=RELEASE .. \
    && make \
    && make install

FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      libjson-c3 \
      libssl1.0.0 \
      libwebsockets8 \
      apt-transport-https \
      software-properties-common \
      gpg-agent \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local/bin/ttyd /ttyd

EXPOSE 7681

ENTRYPOINT ["/ttyd"]

CMD ["bash"]
