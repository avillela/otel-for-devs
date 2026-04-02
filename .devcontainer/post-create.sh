#!/bin/bash

### -------------------
### Uncomment ll command in bashrc
### -------------------

sed -i -e "s/#alias ll='ls -l'/alias ll='ls -al'/g" ~/.bashrc
. $HOME/.bashrc

### -------------------
### Install Java auto-instrumentation agent
### -------------------

curl -L -O https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

### -------------------
### Install Homebrew and otel-tui
### -------------------

./install-homebrew.sh
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && sudo /home/linuxbrew/.linuxbrew/bin/brew install ymtdzzz/tap/otel-tui