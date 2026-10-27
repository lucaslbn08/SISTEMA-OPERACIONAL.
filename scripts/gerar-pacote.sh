#!/bin/bash
# Monta o pacote distro-sistema (.deb) a partir de pacote/.
# Uso: scripts/gerar-pacote.sh <versão> <pasta-de-saída> [chave-pública.gpg] [url-do-canal]
# Com chave e URL, o pacote já ativa o canal de atualizações no sistema onde for instalado.
set -eo pipefail

versao="$1"
saida="$2"
chave="${3:-}"
url="${4:-}"

cd "$(dirname "$0")/.."
. ./distro.conf

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp -a pacote/raiz/. "$tmp/"
cp -a pacote/DEBIAN "$tmp/DEBIAN"
cp distro.conf "$tmp/usr/share/distro/distro.conf"

if [ -n "$chave" ] && [ -n "$url" ]; then
	mkdir -p "$tmp/usr/share/keyrings" "$tmp/usr/share/distro/etc/apt/sources.list.d"
	cp "$chave" "$tmp/usr/share/keyrings/distro-atualizacoes.gpg"
	sed "s|@URL@|$url|" pacote/canal/distro-atualizacoes.sources \
		> "$tmp/usr/share/distro/etc/apt/sources.list.d/distro-atualizacoes.sources"
fi

# Nome e versão do sistema nos arquivos
grep -rlZ -e '@DISTRO_NAME@' -e '@VERSAO@' "$tmp" | xargs -0 -r sed -i \
	-e "s/@DISTRO_NAME@/$DISTRO_NAME/g" -e "s/@VERSAO@/$versao/g"

# Permissões: programas executáveis, o resto só leitura
find "$tmp" -type d -exec chmod 0755 {} +
find "$tmp" -type f -exec chmod 0644 {} +
chmod 0755 "$tmp"/usr/bin/* "$tmp"/usr/sbin/* "$tmp/DEBIAN/postinst"

mkdir -p "$saida"
dpkg-deb --root-owner-group -Zxz --build "$tmp" "$saida/distro-sistema_${versao}_all.deb"
