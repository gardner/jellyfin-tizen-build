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
COPY package /tizen/package

RUN useradd tizen --home-dir /tizen && \
    chmod +x ${TIZEN_STUDIO_FILE} && \
    chown -R tizen:tizen ./ && \
    apt-get update \
    && apt-get install -y expect zip \
    && rm -rf /var/lib/apt/lists/*

USER tizen

RUN ./web-cli_Tizen_Studio_4.5.1_ubuntu-64.bin --accept-license /tizen/tizen-studio && \
    rm ./web-cli_Tizen_Studio_4.5.1_ubuntu-64.bin && \
    echo 'export PATH=$PATH:/tizen/tizen-studio/tools/ide/bin' >> .bashrc && \
    export PATH=$PATH:/tizen/tizen-studio/tools/ide/bin && \
    tizen certificate -a Gardner -p 1234 -c NZ -s Aukland -ct Aukland -o Tizen -n Gardner -e gardner@example.org -f tizencert && \
    tizen security-profiles add -n Gardner -a /tizen/tizen-studio-data/keystore/author/tizencert.p12 -p 1234 && \
    tizen cli-config "profiles.path=/tizen/tizen-studio-data/profile/profiles.xml" && \
    sed -i 's/\/tizen\/tizen-studio-data\/keystore\/author\/tizencert.pwd/1234/g' /tizen/tizen-studio-data/profile/profiles.xml && \
    sed -i 's/\/tizen\/tizen-studio-data\/tools\/certificate-generator\/certificates\/distributor\/tizen-distributor-signer.pwd/tizenpkcs12passfordsigner/g' /tizen/tizen-studio-data/profile/profiles.xml && \
    sed -i 's/password=""/password="tizenpkcs12passfordsigner"/g' /tizen/tizen-studio-data/profile/profiles.xml && \
    chmod 755 /tizen/tizen-studio-data/profile/profiles.xml && \
    cd /tizen/jellyfin-tizen && \
    tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock"

VOLUME ["/output"]
CMD /bin/bash -c "export PATH=$PATH:/tizen/tizen-studio/tools/ide/bin && /tizen/package"
