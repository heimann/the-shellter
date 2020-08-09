# !/bin/bash
st

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

# Add new user and make default shell ZSH
useradd -ms /bin/zsh $1
usermod -aG sudo $1
echo "$1" | passwd --stdin $1
echo -e "$1\n$1" | passwd $1

#wget https://starship.rs/install.sh
#chmod +x install.sh
#./install.sh -y

touch /home/$1/.zshrc
echo "source /home/$1/.config/antigen.zsh" >> /home/$1/.zshrc
echo "" >> /home/$1/.zshrc
echo "alias language='asdf'" >> /home/$1/.zshrc
echo "alias search='so'" >> /home/$1/.zshrc
echo "alias howto='tldr'" >> /home/$1/.zshrc
echo "" >> /home/$1/.zshrc
echo "antigen bundle agkozak/zsh-z" >> /home/$1/.zshrc
echo '[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh' >> /home/$1/.zshrc
echo "" >> /home/$1/.zshrc
echo ". /home/$1/.asdf/asdf.sh" >> /home/$1/.zshrc
chown $1:$1 /home/$1/.zshrc

# Switch to the new user
sudo -u $1 -H zsh -c "cd /home/$1; curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | zsh"
sudo -u $1 -H zsh -c "cd /home/$1; git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0-rc1"
sudo -u $1 -H zsh -c "cd /home/$1; mkdir .config"
sudo -u $1 -H zsh -c "cd /home/$1; curl -L git.io/antigen > .config/antigen.zsh"

su - $1
