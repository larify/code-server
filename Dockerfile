# Start from the code-server Debian base image
FROM codercom/code-server:latest AS base

USER root

# Use bash shell
# ENV SHELL=/bin/bash
ENV SHELL=/bin/zsh

# Install unzip + rclone (support for remote filesystem)
RUN apt-get update && apt-get install curl wget net-tools neovim unzip python-is-python3 -y

# Install nerd fonts
RUN mkdir -p ./fonts && mkdir -p /usr/share/fonts/truetype
COPY fonts ./fonts
RUN install -m644 ./fonts/*.ttf /usr/share/fonts/truetype/ && rm -rf ./fonts

FROM base AS vscode

# Apply VS Code settings
COPY settings.json /root/.local/share/code-server/User/settings.json
COPY dotfiles /root/

# RUN curl https://rclone.org/install.sh | sudo bash

# Install nvm and NodeJS
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | \
  bash
RUN /bin/zsh -c "source $HOME/.nvm/nvm.sh \
  && nvm install --lts \
  && nvm alias default 'lts/*' \
  && npm install -g pnpm"

# Fix permissions for code-server
# RUN chown -R root:root ~/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# RUN code-server --install-extension esbenp.prettier-vscode

RUN code-server --install-extension formulahendry.auto-close-tag \
  && code-server --install-extension formulahendry.auto-rename-tag \
  && code-server --install-extension mgmcdermott.vscode-language-babel \
  && code-server --install-extension aaron-bond.better-comments \
  && code-server --install-extension formulahendry.code-runner \
  && code-server --install-extension streetsidesoftware.code-spell-checker \
  && code-server --install-extension dbaeumer.vscode-eslint \
  && code-server --install-extension mhutchie.git-graph \
  && code-server --install-extension eamodio.gitlens \
  && code-server --install-extension wix.vscode-import-cost \
  && code-server --install-extension yzhang.markdown-all-in-one \
  && code-server --install-extension esbenp.prettier-vscode \
  && code-server --install-extension richie5um2.vscode-sort-json \
  && code-server --install-extension bradlc.vscode-tailwindcss \
  && code-server --install-extension donjayamanne.githistory \
  && code-server --install-extension zhuangtongfa.material-theme \
  && code-server --install-extension PKief.material-icon-theme \
  && code-server --install-extension Vue.volar \
  && code-server --install-extension redhat.vscode-yaml \
  && code-server --install-extension ms-azuretools.vscode-docker

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

FROM vscode AS runner

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY entrypoint.sh /usr/bin/code-server-entrypoint.sh
RUN chmod +x /usr/bin/code-server-entrypoint.sh

ENTRYPOINT ["/usr/bin/code-server-entrypoint.sh"]
