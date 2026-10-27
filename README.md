# MeuOS

Sistema operacional próprio baseado em **Debian 13**, com visual no estilo macOS (KDE Plasma 6 + tema WhiteSur), feito para trabalho no dia a dia.

> O nome "MeuOS" é provisório. Para trocar, edite `distro.conf`.

## O que vem nele

- **Visual estilo Mac**: barra de menu no topo, dock embaixo, janelas com botões à esquerda
- **Google Chrome** como navegador padrão
- **WhatsApp** e **Canva** como apps próprios no dock
- **LibreOffice** (Word, Excel e PowerPoint compatíveis)
- **Loja de apps** (Discover + Flathub)
- **Pontos de restauração** automáticos antes de cada atualização (Btrfs + Timeshift)
- **Canal de atualizações próprio**: melhorias chegam sem reinstalar
- **Papel de parede de dia e de noite** (troca às 6h e às 18h)
- **Pasta cofre** com senha (Plasma Vault) e **firewall** ligado
- **Google Drive** (app e pasta no gerenciador de arquivos) e **Bambu Studio** (instalado sozinho quando houver internet)
- Português do Brasil, teclado ABNT2, Wi-Fi, Bluetooth, impressoras e scanners

## Como baixar o .iso

1. Abra a aba **Actions** deste repositório
2. Clique na execução mais recente de **Gerar ISO** com o ícone verde
3. Em **Artifacts**, baixe **iso**: é um .zip com o arquivo `.iso` dentro

## Como testar e instalar

1. Grave o `.iso` num pendrive (mínimo 8 GB) com o [Balena Etcher](https://etcher.balena.io/) ou o [Rufus](https://rufus.ie/)
2. Ligue o notebook e entre no menu de boot (geralmente **F12**, **F9** ou **Esc** ao ligar)
3. Escolha o pendrive: o sistema abre em modo **Live**, sem mexer no disco
4. Testou e gostou? Clique em **Instalar** na área de trabalho

⚠️ A instalação apaga o disco. Faça backup dos seus arquivos antes.

## Canal de atualizações

Tudo o que é próprio do sistema fica no pacote `distro-sistema` (pasta `pacote/`). A cada mudança nessa
pasta, o workflow **Publicar atualização** monta o pacote, assina e publica no branch `atualizacoes`.
O note vê a atualização na Loja (Discover) junto com as do Debian.

Requisitos (uma vez só):
1. Repositório **público** (o note baixa as atualizações sem senha).
2. Segredo **`CHAVE_ATUALIZACOES`** em *Settings → Secrets and variables → Actions* com a chave privada de assinatura.

Para ativar o canal num sistema instalado antes dele existir:

```sh
wget -O /tmp/distro-sistema.deb https://raw.githubusercontent.com/lucaslbn08/SISTEMA-OPERACIONAL./atualizacoes/distro-sistema_atual.deb
sudo apt install /tmp/distro-sistema.deb
```

## Estrutura do projeto

| Caminho | Conteúdo |
|---|---|
| `distro.conf` | Nome e versão do sistema |
| `auto/config` | Configuração do live-build (Debian 13, idioma, boot) |
| `config/package-lists/` | Programas instalados no pendrive |
| `config/hooks/live/` | Instalam o tema e ajustam o instalador |
| `pacote/` | Pacote `distro-sistema`: layout, ícones, papéis de parede, scripts, configurações |
| `scripts/` | Montam e publicam o pacote |
| `testes/` | Testes em máquina virtual (sessão Live e instalação completa) |
| `assets/gerar-imagens.py` | Gera os papéis de parede (dia e noite) |
| `.github/workflows/` | Gerar ISO, Publicar atualização e Testar ISO |

## Gerar localmente (opcional)

Em um Debian 13 com `live-build` instalado, como root:

```sh
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub -o config/archives/google-chrome.key.chroot
cp config/archives/google-chrome.key.chroot config/archives/google-chrome.key.binary
scripts/gerar-pacote.sh 1.0.0 config/packages.chroot
lb config && lb build
```
