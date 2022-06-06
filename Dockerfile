FROM node:10-buster AS builder

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get -qq update \
  && apt-get -y --no-install-recommends install \
      apt-transport-https \
      curl \
      unzip \
      build-essential \
      python \
      libcairo2-dev \
      libgles2-mesa-dev \
      libgbm-dev \
      libllvm7 \
      libprotobuf-dev \
  && apt-get -y --purge autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY . /usr/src/app

ENV NODE_ENV="production"

RUN cd /usr/src/app && npm install --production


FROM node:10-buster-slim AS final

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get -qq update \
  && apt-get -y --no-install-recommends install \
      libgles2-mesa \
      ca-certificates \
      rsync \
      git \
      libegl1 \
      xvfb \
      xauth \
  && apt-get -y --purge autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app /app

RUN git clone https://github.com/cartologic/openmaptiles-fonts
RUN rsync -av openmaptiles-fonts/fonts /app/node_modules/tileserver-gl-styles/fonts

ENV NODE_ENV="production"
ENV CHOKIDAR_USEPOLLING=1
ENV CHOKIDAR_INTERVAL=500

VOLUME /data
WORKDIR /data

EXPOSE 7021

USER node:node

ENTRYPOINT ["/app/docker-entrypoint.sh"]

CMD ["-p", "7021"]
