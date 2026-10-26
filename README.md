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

## Estrutura do projeto

| Caminho | Conteúdo |
|---|---|
| `distro.conf` | Nome e versão do sistema |
| `auto/config` | Configuração do live-build (Debian 13, idioma, boot) |
| `config/package-lists/` | Programas instalados |
| `config/hooks/live/` | Scripts que instalam o tema e aplicam a identidade |
| `config/includes.chroot/` | Arquivos copiados para o sistema (layout, ícones, papel de parede) |
| `assets/gerar-imagens.py` | Gera o papel de parede |
| `.github/workflows/gerar-iso.yml` | Gera o .iso automaticamente a cada mudança |

## Gerar localmente (opcional)

Em um Debian 13 com `live-build` instalado, como root:

```sh
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub -o config/archives/google-chrome.key.chroot
cp config/archives/google-chrome.key.chroot config/archives/google-chrome.key.binary
lb config && lb build
```
