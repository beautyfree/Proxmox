#!/usr/bin/env bash

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y cifs-utils
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip
msg_ok "Updated Python3"

# msg_info "Installing Motion"
# $STD apt-get install -y motion
# systemctl stop motion
# $STD systemctl disable motion
# msg_ok "Installed Motion"

# msg_info "Installing FFmpeg"
# $STD apt-get install -y ffmpeg v4l-utils
# msg_ok "Installed FFmpeg"

msg_info "Installing Pytorch"
$STD pip install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
msg_ok "Installed Pytorch"

msg_info "Installing AutoGPTQ"
$STD pip install auto-gptq
msg_ok "Installed AutoGPTQ"

msg_info "Installing WizardCoder"
mkdir repositories
cd repositories
git clone https://github.com/mzbac/AutoGPTQ-API && cd AutoGPTQ-API
$STD apt-get update
$STD pip install .
$STD pip install -r requirements.txt
if [ ! -f cert.pem ] || [ ! -f key.pem ]; then
openssl req -x509 -out cert.pem -keyout key.pem \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
fi
$STD python download.py TheBloke/WizardCoder-15B-1.0-GPTQ
$STD python blocking_api.py
msg_ok "Installed WizardCoder"

# msg_info "Creating Service"
# wget -qO /etc/systemd/system/motioneye.service https://raw.githubusercontent.com/motioneye-project/motioneye/dev/motioneye/extra/motioneye.systemd
# systemctl enable -q --now motioneye
# msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
