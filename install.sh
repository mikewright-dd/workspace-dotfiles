#!/usr/bin/env bash

set -euo pipefail

DOTFILES_PATH="$HOME/dotfiles"

# Symlink dotfiles to the root within your workspace
find $DOTFILES_PATH -type f -path "$DOTFILES_PATH/.*" |
while read df; do
  link=${df/$DOTFILES_PATH/$HOME}
  mkdir -p "$(dirname "$link")"
  ln -sf "$df" "$link"
done

sudo apt-get update
sudo apt-get install -y rsync silversearcher-ag
curl -L https://binaries.ddbuild.io/service-discovery-platform/fabric_1.117.1_linux_amd64.tar.gz -o fabric.tgz && tar -xvf fabric.tgz && mv ./fabric $HOME/.local/bin
cp $DOTFILES_PATH/git-pre-commit ~/dd/dd-source/.git/hooks/;
touch $HOME/.dotfiles_installed

# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Attempt to install Vim Plugins
vim -c 'PlugInstall' \
    -c 'qa!'

# This has a bunch of depenedencies which may need to be resolved, specifically
# Vim compiled with Python3, python-dev, ruby-dev, golang, and Clang.
pushd ~/.vim/pluggd/YouCompleteMe
python3 install.py --all
popd

# This may require further compilation to get working.
pushd ~/.vim/pluggs/command-t
make
popd
