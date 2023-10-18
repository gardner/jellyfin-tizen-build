## Build jellyfin-web
FROM node:20

ENV JELLYFIN_WEB_URL=https://github.com/jellyfin/jellyfin-web/archive/refs/tags/v10.8.11.tar.gz
ENV JELLYFIN_TIZEN_URL=https://github.com/jellyfin/jellyfin-tizen/archive/refs/heads/master.tar.gz

WORKDIR /jellyfin

RUN curl -sL ${JELLYFIN_WEB_URL} | tar -xz && \
    mv jellyfin-web-* jellyfin-web && \
    cd jellyfin-web && \
    npx browserslist@latest --update-db && \
    SKIP_PREPARE=1 npm ci --no-audit && \
    npm run build:production && \
    cd .. && \
    curl -sL ${JELLYFIN_TIZEN_URL} | tar -xz && \
    mv jellyfin-tizen-* jellyfin-tizen && \
    cd jellyfin-tizen && \
    JELLYFIN_WEB_DIR=../jellyfin-web/dist npm ci --no-audit

## Build jellyfin app
FROM eclipse-temurin:11

ARG TIZEN_STUDIO_VER=5.1
ENV TIZEN_STUDIO_URL=https://download.tizen.org/sdk/Installer/tizen-studio_${TIZEN_STUDIO_VER}/web-cli_Tizen_Studio_${TIZEN_STUDIO_VER}_ubuntu-64.bin
ENV TIZEN_STUDIO_FILE=web-cli_Tizen_Studio_${TIZEN_STUDIO_VER}_ubuntu-64.bin

WORKDIR /tizen

COPY --from=0 /jellyfin/jellyfin-tizen ./jellyfin-tizen
COPY package.sh /tizen/package.sh
COPY expect_script /tizen/expect_script

RUN curl -L "${TIZEN_STUDIO_URL}" --output "${TIZEN_STUDIO_FILE}" \
    && useradd tizen --home-dir /tizen \
    && chmod +x "${TIZEN_STUDIO_FILE}" \
    && chown -R tizen:tizen ./ \
    && apt-get update \
    && apt-get install -y expect zip \
    && rm -rf /var/lib/apt/lists/*

USER tizen

RUN echo 'export PATH=$PATH:/tizen/tizen-studio/tools/ide/bin' >> .bashrc \
    && ./web-cli_Tizen_Studio_${TIZEN_STUDIO_VER}_ubuntu-64.bin --accept-license /tizen/tizen-studio \
    && rm ./web-cli_Tizen_Studio_${TIZEN_STUDIO_VER}_ubuntu-64.bin


VOLUME ["/output"]
VOLUME [ "/tizen/tizen-studio-data/keystore/author" ]
CMD /tizen/package.sh
