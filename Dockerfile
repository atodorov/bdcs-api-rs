# A Fedora 24 BDCS API Container
FROM fedora:24
MAINTAINER Brian C. Lane <bcl@redhat.com>

RUN dnf install -y dnf-plugins-core gnupg tar git sudo curl file gcc-c++ gcc gdb glibc-devel openssl-devel make xz sqlite-devel openssl-devel

ENV RUST_VERSION 1.13.0

RUN curl -sSf https://static.rust-lang.org/rustup.sh \
  | sh -s -- --yes --disable-sudo --revision=$RUST_VERSION \
  && rustc --version && cargo --version

ENV CARGO_HOME /cargo
ENV SRC_PATH /src

RUN mkdir -p "$CARGO_HOME" "$SRC_PATH"
WORKDIR $SRC_PATH

RUN echo 'PATH=/usr/local/bin/:$PATH' >> /etc/bashrc

# Based on official node docker image
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.7.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 80

# Volumes for database and recipe storage.
VOLUME /bdcs-db /bdcs-recipes

## Do the things more likely to change below here. ##

# Update node dependencies only if they have changed
COPY ./share/composer-UI/package.json /composer-UI/package.json
RUN cd /composer-UI/ && npm install

# Copy the rest of the UI files over and compile them
COPY ./share/composer-UI/ /composer-UI/
RUN cd /composer-UI/ && node run build

COPY . /bdcs-api-rs/
RUN cd /bdcs-api-rs/ && cargo build
