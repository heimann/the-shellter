# !/bin/bash

# Ensure user passed enough args
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <github user name>" >&2
  exit 1
fi

# Make sure user name is not empty
if [ -z "$1" ]; then
  echo "Username is empty. Exiting"
  exit 1
fi

# Make sure the container exists
#CTNR_EXISTS=`docker ps -a -q --no-trunc | grep $1`
#echo $CTNR_EXISTS
#if [ -z "$CTNR_EXISTS" ]; then
#  echo "Container doesn't exist. Exiting.."
#  exit 1
#fi

USERNAME="$1"
HOME_DIR="/home/$USERNAME"
ZSHRC="/$HOME_DIR/.zshrc"

# Add new user and make default shell ZSH
useradd -ms /bin/zsh $USERNAME
usermod -aG sudo $USERNAME
echo "$USERNAME" | passwd --stdin $USERNAME
echo -e "$USERNAME\n$USERNAME" | passwd $USERNAME

touch $ZSHRC
echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then' >> $ZSHRC
echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"' >> $ZSHRC
echo 'fi' >> $ZSHRC

echo "alias language='asdf'" >> /home/$1/.zshrc
echo "alias search='so'" >> /home/$1/.zshrc
echo "alias howto='tldr'" >> /home/$1/.zshrc

echo "" >> /home/$1/.zshrc
echo '[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh' >> /home/$1/.zshrc
echo "" >> /home/$1/.zshrc
echo ". /home/$1/.asdf/asdf.sh" >> /home/$1/.zshrc
echo ". $HOME_DIR/.config/zsh-z.plugin.zsh" >> $ZSHRC

echo "" >> /home/$1/.zshrc

echo "# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh." >> /home/$1/.zshrc
echo ". /home/$1/.config/powerlevel10k/powerlevel10k.zsh-theme" >> /home/$1/.zshrc
echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> $ZSHRC

chown $USERNAME:$USERNAME /home/$USERNAME/.zshrc
cp /tmp/.p10k.zsh $HOME_DIR
chown $USERNAME:$USERNAME $HOME_DIR/.p10k.zsh

# Switch to the new user
sudo -u $1 -H zsh -c "cd /home/$1; curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | zsh"
sudo -u $1 -H zsh -c "cd /home/$1; git clone --depth=1 https://github.com/romkatv/powerlevel10k.git .config/powerlevel10k"
sudo -u $1 -H zsh -c "cd /home/$1; git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0-rc1"
sudo -u $1 -H zsh -c "cd /home/$1; curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
sudo -u $1 -H zsh -c "cd /home/$1; git clone https://github.com/garabik/grc.git; sh grc/install.sh; rm -rf grc"
sudo -u $1 -H zsh -c "cd /home/$1; wget -P .config/ https://raw.githubusercontent.com/agkozak/zsh-z/master/zsh-z.plugin.zsh"
sudo -u $1 -H zsh -c "cd /home/$1; git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; cd .fzf; ./install --all"

su - $USERNAME
