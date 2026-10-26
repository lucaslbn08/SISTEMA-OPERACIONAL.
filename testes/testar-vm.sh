#!/bin/bash
# Liga o .iso numa máquina virtual (QEMU) e tira prints da tela em momentos marcados.
# Uso: testes/testar-vm.sh <arquivo.iso> <pasta-dos-prints>
set -eo pipefail

iso="$1"
telas="$2"
mon=/tmp/monitor-qemu
mkdir -p "$telas"

monitor() { echo "$1" | socat - "UNIX-CONNECT:$mon" > /dev/null; }

print() {
	monitor "screendump /tmp/tela.ppm"
	sleep 2
	convert /tmp/tela.ppm "$telas/$1.png"
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
			'|') tecla=shift-less ;;
			'.') tecla=dot ;;
			'/') tecla=ralt-q ;;
			*) continue ;;
		esac
		monitor "sendkey $tecla"
	done
	monitor "sendkey ret"
}

qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -cpu host \
	-bios /usr/share/ovmf/OVMF.fd -vga none -device virtio-vga,xres=1440,yres=900 -display none \
	-cdrom "$iso" -boot d \
	-monitor "unix:$mon,server,nowait" &
qemu=$!

sleep 15
monitor "sendkey ret"   # caso o menu de boot não inicie sozinho
sleep 15;  print 01-carregando
sleep 30;  print 02-iniciando
sleep 45;  print 03-area-de-trabalho

monitor "sendkey meta_l-e"   # gerenciador de arquivos
sleep 20;  print 04-janela

monitor "sendkey ctrl-alt-t" # terminal
sleep 15
digitar "clear"
digitar "kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key library"
digitar "kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme"
sleep 10;  print 05-diagnostico

kill "$qemu" || true
