# Liga a troca automática do papel de parede (dia/noite) para quem já usava o sistema
systemctl --user daemon-reload
systemctl --user start distro-papel-de-parede.timer
sleep 10
distro-papel-de-parede
