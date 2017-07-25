FROM openjdk:8u131

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci && \
    echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci  && \
    apt-get update && \
    apt-get install apt-transport-https lsb-release > /dev/null 2>&1

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install docker-ce

RUN JQ_URL=$(curl --location --fail --retry 3 https://api.github.com/repos/stedolan/jq/releases/latest  | grep browser_download_url | grep '/jq-linux64"' | grep -o -e 'https.*jq-linux64') \
  && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/jq $JQ_URL \
  && chmod +x /usr/bin/jq

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_6.x stretch main' > /etc/apt/sources.list.d/nodesource.list && \
    echo 'deb-src https://deb.nodesource.com/node_6.x stretch main' >> /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install nodejs=6.*

RUN npm install --global semver@5.3.0

RUN wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh

ADD entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Should always be the last line as it is the one that will change most regularly
ADD bash_libs /home/circleci/bash_libs
