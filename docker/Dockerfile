FROM ubuntu

#LABEL maintainer=""
LABEL version="0.1"
LABEL description="Base image for theshellter"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y htop curl sudo git wget vim neovim zsh fzf ripgrep tmux
RUN chsh -s /usr/bin/zsh
ADD post_launch.sh /tmp
ADD .p10k.zsh /tmp
