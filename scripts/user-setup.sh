## NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

## Node / Yarn
source ~/.nvm/nvm.sh
nvm install 12.16.3
nvm alias default 12.16.3
npm install --global yarn

echo "cd ~/code" >> ~/.bashrc