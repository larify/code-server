#!/bin/sh
set -eu

# We do this first to ensure sudo works below when renaming the user.
# Otherwise the current container UID may not exist in the passwd database.
eval "$(fixuid -q)"

if [ "${DOCKER_USER-}" ]; then
  USER="$DOCKER_USER"
  if [ "$DOCKER_USER" != "$(whoami)" ]; then
    echo "$DOCKER_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/nopasswd > /dev/null
    # Unfortunately we cannot change $HOME as we cannot move any bind mounts
    # nor can we bind mount $HOME into a new home as that requires a privileged container.
    sudo usermod --login "$DOCKER_USER" coder
    sudo groupmod -n "$DOCKER_USER" coder

    sudo sed -i "/coder/d" /etc/sudoers.d/nopasswd
  fi
fi

# Allow users to have scripts run on container startup to prepare workspace.
# https://github.com/coder/code-server/issues/5177
if [ -d "${ENTRYPOINTD}" ]; then
  find "${ENTRYPOINTD}" -type f -executable -print -exec {} \;
fi

# Set git safe directory
/usr/bin/git config --global --add safe.directory "*"
/usr/bin/git config --global pull.rebase true

# Install extensions
extensions="\
    dbaeumer.vscode-eslint \
    donjayamanne.githistory \
    eamodio.gitlens \
    esbenp.prettier-vscode \
    jock.svg \
    kisstkondoros.vscode-gutter-preview \
    mhutchie.git-graph \
    mikestead.dotenv \
    ms-azuretools.vscode-containers \
    pkief.material-icon-theme \
    richie5um2.vscode-sort-json \
    streetsidesoftware.code-spell-checker \
    tamasfe.even-better-toml \
    vstirbu.vscode-mermaid-preview \
    vue.volar \
    wayou.vscode-todo-highlight \
    wix.vscode-import-cost \
    yzhang.markdown-all-in-one \
    zhuangtongfa.material-theme \
"

for ext in $extensions; do
  [ -n "$ext" ] && /usr/bin/code-server --install-extension "$ext"
done

# Start server
exec dumb-init /usr/bin/code-server "$@"
