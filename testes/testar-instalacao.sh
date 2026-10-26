#!/bin/bash
# Abre o instalador na máquina virtual (com um disco vazio de 40 GB) e tira prints de cada etapa.
# Uso: testes/testar-instalacao.sh <arquivo.iso> <pasta-dos-prints>
set -eo pipefail

iso="$1"
telas="$2"
mon=/tmp/monitor-qemu
mkdir -p "$telas"

monitor() { echo "$1" | socat - "UNIX-CONNECT:$mon" > /dev/null; }

# Clica com o mouse na posição (x, y) de uma tela 1440x900
qmp=/tmp/qmp-qemu
clicar() {
	local x=$(($1 * 32767 / 1440)) y=$(($2 * 32767 / 900)) cmd
	cmd='{"execute":"qmp_capabilities"}'
	cmd+=$'\n{"execute":"input-send-event","arguments":{"events":[{"type":"abs","data":{"axis":"x","value":'$x'}},{"type":"abs","data":{"axis":"y","value":'$y'}}]}}'
	cmd+=$'\n{"execute":"input-send-event","arguments":{"events":[{"type":"btn","data":{"down":true,"button":"left"}}]}}'
	cmd+=$'\n{"execute":"input-send-event","arguments":{"events":[{"type":"btn","data":{"down":false,"button":"left"}}]}}'
	printf '%s\n' "$cmd" | socat -t 2 - "UNIX-CONNECT:$qmp" > /dev/null
	sleep 1
}

n=0
print() {
	n=$((n + 1))
	monitor "screendump /tmp/tela.ppm"
	sleep 2
	convert /tmp/tela.ppm "$telas/$(printf %02d $n)-$1.png"
}

# Digita um texto com teclado ABNT2
digitar() {
	local texto="$1" i c tecla
	for ((i = 0; i < ${#texto}; i++)); do
		c="${texto:i:1}"
		case "$c" in
			[a-z0-9]) tecla="$c" ;;
			' ') tecla=spc ;;
			'-') tecla=minus ;;
			'.') tecla=dot ;;
			*) continue ;;
		esac
		monitor "sendkey $tecla"
	done
}

qemu-img create -f qcow2 /tmp/disco.qcow2 40G
cp /usr/share/OVMF/OVMF_VARS_4M.fd /tmp/vars.fd

qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -cpu host \
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
	-drive if=pflash,format=raw,file=/tmp/vars.fd \
	-vga none -device virtio-vga,xres=1440,yres=900 -display none \
	-drive file=/tmp/disco.qcow2,if=virtio \
	-cdrom "$iso" -boot d \
	-device qemu-xhci -device usb-tablet \
	-monitor "unix:$mon,server,nowait" -qmp "unix:$qmp,server,nowait" &
qemu=$!

sleep 15
monitor "sendkey ret"
sleep 75; print area-de-trabalho

# Abre o instalador pelo terminal
monitor "sendkey ctrl-alt-t"
sleep 10
# Mesmo comando do atalho "Instalar" da área de trabalho
digitar "kstart --application calamares-install-debian"
monitor "sendkey ret"
sleep 30; print instalador-aberto

# Avança as etapas clicando em "Próximo", registrando cada tela
for etapa in boas-vindas localizacao teclado; do
	clicar 1106 781
	sleep 6; print "depois-$etapa"
done

# Partições: "Formatar o disco"
clicar 404 269
sleep 4; print particoes-formatar
clicar 1106 781
sleep 6; print usuarios

kill "$qemu" || true
