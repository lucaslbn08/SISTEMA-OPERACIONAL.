#!/bin/bash
# Publica o pacote no canal de atualizações (branch "atualizacoes" do repositório, servido pelo GitHub).
# Uso: scripts/publicar-canal.sh <pacote.deb> <pasta-do-canal>
# A pasta do canal é um clone do branch; a chave privada de assinatura deve estar no gpg.
set -eo pipefail

deb="$1"
canal="$2"

cp "$deb" "$canal/"
cd "$canal"
rm -f distro-sistema_atual.deb

# Mantém só as 3 versões mais recentes
ls -1 distro-sistema_*_all.deb | sort -V | head -n -3 | xargs -r rm -f

apt-ftparchive packages . > Packages
gzip -kf Packages
rm -f Release InRelease Release.gpg
apt-ftparchive -o APT::FTPArchive::Release::Origin="distro" -o APT::FTPArchive::Release::Label="distro" release . > /tmp/Release
mv /tmp/Release Release
gpg --batch --yes --clearsign -o InRelease Release
gpg --batch --yes -abs -o Release.gpg Release

# Cópia com nome fixo, para ativar o canal num sistema já instalado (fora do índice)
cp "$(ls -1 distro-sistema_*_all.deb | sort -V | tail -n 1)" distro-sistema_atual.deb
