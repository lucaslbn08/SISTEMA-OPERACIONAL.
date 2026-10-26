#!/bin/bash
# Abre o instalador na máquina virtual (com um disco vazio de 40 GB) e tira prints de cada etapa.
# Uso: testes/testar-instalacao.sh <arquivo.iso> <pasta-dos-prints>
set -eo pipefail

iso="$1"
telas="$2"
mon=/tmp/monitor-qemu
mkdir -p "$telas"

monitor() { echo "$1" | socat - "UNIX-CONNECT:$mon" > /dev/null; }

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
	-monitor "unix:$mon,server,nowait" &
qemu=$!

sleep 15
monitor "sendkey ret"
sleep 75; print area-de-trabalho

# Abre o instalador pelo terminal
monitor "sendkey ctrl-alt-t"
sleep 10
digitar "install-debian"
monitor "sendkey ret"
sleep 25; print instalador-aberto

# Avança as etapas com "Próximo" (Alt+P), registrando cada tela
for etapa in boas-vindas localizacao teclado particoes; do
	monitor "sendkey alt-p"
	sleep 6; print "depois-$etapa"
done

kill "$qemu" || true
