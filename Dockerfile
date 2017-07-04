FROM circleci/openjdk:8u131-jdk-browsers

RUN cd ~ && \
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh && \
    sudo bash nodesource_setup.sh && \
    sudo apt-get install nodejs=6.11.0-1nodesource1~jessie1

RUN sudo npm install --global semver@5.3.0

RUN wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh

RUN echo "if [ -e /var/run/docker.sock ]; then sudo chown circleci:circleci /var/run/docker.sock; fi" >> /home/circleci/.bashrc

# Should always be the last line as it is the one that will change most regularly
ADD bash_libs /home/circleci/bash_libs
