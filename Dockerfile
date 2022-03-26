## Build jellyfin-web
FROM node:14

ENV JELLYFIN_WEB_URL=https://github.com/jellyfin/jellyfin-web/archive/refs/heads/master.tar.gz
ENV JELLYFIN_TIZEN_URL=https://github.com/jellyfin/jellyfin-tizen/archive/refs/heads/master.tar.gz

WORKDIR /jellyfin

RUN curl -sL ${JELLYFIN_WEB_URL} | tar -xz && \
    mv jellyfin-web-master jellyfin-web && \
    cd jellyfin-web && \
    npx browserslist@latest --update-db && \
    npm ci --no-audit && \
    cd .. && \
    curl -sL ${JELLYFIN_TIZEN_URL} | tar -xz && \
    mv jellyfin-tizen-master jellyfin-tizen && \
    cd jellyfin-tizen && \
    JELLYFIN_WEB_DIR=../jellyfin-web/dist yarn install

## Build jellyfin app
FROM adoptopenjdk/openjdk8

ENV TIZEN_STUDIO_VER=4.5.1
ENV TIZEN_STUDIO_URL=https://download.tizen.org/sdk/Installer/tizen-studio_${TIZEN_STUDIO_VER}/web-cli_Tizen_Studio_${TIZEN_STUDIO_VER}_ubuntu-64.bin
ENV TIZEN_STUDIO_FILE=web-cli_Tizen_Studio_${TIZEN_STUDIO_VER}_ubuntu-64.bin

WORKDIR /tizen

ADD ${TIZEN_STUDIO_URL} ${TIZEN_STUDIO_FILE}

COPY --from=0 /jellyfin/jellyfin-tizen ./jellyfin-tizen
COPY package.sh /tizen/package.sh
COPY expect_script /tizen/expect_script

RUN useradd tizen --home-dir /tizen && \
    chmod +x ${TIZEN_STUDIO_FILE} && \
    chown -R tizen:tizen ./ && \
    apt-get update \
    && apt-get install -y expect zip \
    && rm -rf /var/lib/apt/lists/*

USER tizen

RUN ./web-cli_Tizen_Studio_4.5.1_ubuntu-64.bin --accept-license /tizen/tizen-studio && \
    rm ./web-cli_Tizen_Studio_4.5.1_ubuntu-64.bin && \
    echo 'export PATH=$PATH:/tizen/tizen-studio/tools/ide/bin' >> .bashrc

VOLUME ["/output"]
CMD /tizen/package.sh
