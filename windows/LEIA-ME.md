# Windows 11 leve + MeuOS no mesmo note

Ao ligar o note aparece um menu para escolher **MeuOS** ou **Windows**.

## O que tem aqui

| Arquivo | O que faz |
|---|---|
| `pendrive/autounattend.xml` | Responde a instalação do Windows sozinho: português, teclado ABNT2, fuso de Brasília, sem conta Microsoft, sem telas de propaganda, sem criptografia automática do disco |
| `pendrive/leve/pos-instalacao.ps1` | No primeiro login: ponto de restauração, remove apps inúteis e OneDrive, desliga propagandas/Bing/widgets/Copilot/telemetria, acerta o relógio para conviver com o Linux, desliga a inicialização rápida e instala Chrome, WhatsApp, Canva, Google Drive, Bambu Studio, VLC e 7-Zip |

Baixe os dois prontos em **Actions → Arquivos do Windows → Artifacts → arquivos-pendrive-windows**.

## Passo a passo

### 0. Antes
- Copie para fora (pendrive, Google Drive) o que você salvou no MeuOS: **o disco todo será apagado**.
- Note no carregador e com Wi-Fi.

### 1. Pendrive do Windows (8 GB ou mais)
**Jeito mais simples (precisa de um PC com Windows emprestado):**
1. No PC com Windows, baixe a **Ferramenta de Criação de Mídia** em microsoft.com/software-download/windows11
2. Crie o pendrive com ela (idioma Português do Brasil)
3. Copie para a **raiz do pendrive** o arquivo `autounattend.xml` e a pasta `leve`

**Pelo próprio note (MeuOS), com o Ventoy:** veja a seção "Ventoy" no fim.

### 2. Instalar o Windows
1. Ligue o note pelo pendrive do Windows (F12 ao ligar)
2. A instalação já vem em português. Quando pedir a chave do produto, clique em **"Não tenho a chave"**: o note ativa sozinho se veio com Windows. Se perguntar a edição, escolha a mesma que veio no note (geralmente **Home**)
3. Na tela **"Onde você deseja instalar o Windows?"**: apague **todas as partições do Disco 0** (o SSD de ~223 GB, **não** o pendrive), selecione o **Espaço não alocado** e clique em **Avançar**
4. Na configuração, conecte no Wi-Fi e crie seu **usuário e senha** (sem conta Microsoft)
5. No primeiro login, uma janela azul do PowerShell trabalha sozinha por 10 a 30 minutos. **Não feche.** No fim aparece "Pronto!": reinicie

### 3. Instalar o MeuOS ao lado
1. Ligue pelo pendrive do MeuOS e abra **Instalar MeuOS**
2. Em **Partições**, escolha **"Instalar lado a lado"**
3. Arraste a divisória: **Windows ~120 GB**, **MeuOS ~100 GB**
4. Siga como antes. No fim, o menu de inicialização mostra os dois sistemas

### Ventoy (criar o pendrive do Windows a partir do MeuOS)
1. Baixe o Ventoy para Linux em ventoy.net (arquivo `ventoy-x.x.x-linux.tar.gz`), descompacte e abra `VentoyGUI.x86_64`
2. Escolha o pendrive e clique em **Install** (apaga o pendrive)
3. Baixe o ISO do Windows 11 em microsoft.com/software-download/windows11 (no Linux o site oferece o ISO direto)
4. Copie para o pendrive: o ISO do Windows, o ISO do MeuOS, o `autounattend.xml` e a pasta `leve`
5. Ao ligar pelo pendrive, o Ventoy mostra um menu para escolher o ISO. Se aparecer "Verification failed", escolha **Enroll key from disk → ENROLL_THIS_KEY_IN_MOKMANAGER.cer → Continue → Yes** e reinicie (só na primeira vez)
