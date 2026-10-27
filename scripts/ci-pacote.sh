#!/bin/bash
# No GitHub Actions: monta o pacote distro-sistema e, se possível, publica no canal de atualizações.
# Uso: scripts/ci-pacote.sh <pasta-de-saída>
# Ambiente: GITHUB_REPOSITORY, GH_TOKEN e (opcional) CHAVE_ATUALIZACOES, a chave privada de assinatura.
#
# O canal só é ativado quando há chave e o repositório é público: o note baixa as atualizações
# sem senha, direto do GitHub.
set -eo pipefail

saida="$1"
cd "$(dirname "$0")/.."
. ./distro.conf

versao="$DISTRO_VERSION.$(date -u +%Y%m%d%H%M)"
url="https://raw.githubusercontent.com/$GITHUB_REPOSITORY/atualizacoes/"
echo "versao=$versao" >> "${GITHUB_OUTPUT:-/dev/null}"

publico=no
curl -fsI "https://raw.githubusercontent.com/$GITHUB_REPOSITORY/main/distro.conf" > /dev/null && publico=yes

if [ -z "$CHAVE_ATUALIZACOES" ] || [ "$publico" != yes ]; then
	echo "::warning::Canal de atualizações desativado (chave CHAVE_ATUALIZACOES ausente ou repositório privado)."
	scripts/gerar-pacote.sh "$versao" "$saida"
	exit 0
fi

GNUPGHOME=$(mktemp -d)
export GNUPGHOME
echo "$CHAVE_ATUALIZACOES" | gpg --batch --import
gpg --export > "$GNUPGHOME/publica.gpg"
scripts/gerar-pacote.sh "$versao" "$saida" "$GNUPGHOME/publica.gpg" "$url"

repo="https://x-access-token:$GH_TOKEN@github.com/$GITHUB_REPOSITORY"
canal=$(mktemp -d)
git clone -q --depth 1 -b atualizacoes "$repo" "$canal" 2> /dev/null || true
rm -rf "$canal/.git"
scripts/publicar-canal.sh "$saida/distro-sistema_${versao}_all.deb" "$canal"

# O branch guarda só o estado atual, sem histórico (não cresce com o tempo)
cd "$canal"
git init -q -b atualizacoes
git config user.name "github-actions"
git config user.email "github-actions@users.noreply.github.com"
git add -A
git commit -q -m "distro-sistema $versao"
git push -q -f "$repo" atualizacoes
echo "Publicado: distro-sistema $versao em $url"
