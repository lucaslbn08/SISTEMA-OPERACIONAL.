// Layout padrão da área de trabalho: barra de menu no topo e dock embaixo, como no macOS.

// Papel de parede
var telas = desktops();
for (var i = 0; i < telas.length; i++) {
    var d = telas[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    d.writeConfig("Image", "file:///usr/share/wallpapers/Distro/");
}

// Barra de menu (topo)
var topo = new Panel;
topo.location = "top";
topo.height = Math.round(gridUnit * 1.5);
topo.floating = false;

var menu = topo.addWidget("org.kde.plasma.kickoff");
menu.currentConfigGroup = ["General"];
menu.writeConfig("icon", "distro-logo");

topo.addWidget("org.kde.plasma.appmenu");
topo.addWidget("org.kde.plasma.panelspacer");
topo.addWidget("org.kde.plasma.systemtray");

var relogio = topo.addWidget("org.kde.plasma.digitalclock");
relogio.currentConfigGroup = ["Appearance"];
relogio.writeConfig("showDate", true);
relogio.writeConfig("dateDisplayFormat", "BesideTime");

// Dock (embaixo)
var dock = new Panel;
dock.location = "bottom";
dock.height = Math.round(gridUnit * 3.2);
dock.floating = true;
dock.lengthMode = "fit";
dock.alignment = "center";
dock.hiding = "dodgewindows";

var tarefas = dock.addWidget("org.kde.plasma.icontasks");
tarefas.currentConfigGroup = ["General"];
tarefas.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:google-chrome.desktop",
    "applications:firefox-esr.desktop",
    "applications:distro-whatsapp.desktop",
    "applications:distro-canva.desktop",
    "applications:libreoffice-writer.desktop",
    "applications:libreoffice-calc.desktop",
    "applications:org.kde.discover.desktop",
    "applications:systemsettings.desktop"
]);
tarefas.writeConfig("showOnlyCurrentDesktop", false);

dock.addWidget("org.kde.plasma.marginsseparator");
dock.addWidget("org.kde.plasma.trash");
