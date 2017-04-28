<!--
Multi-Monitor-Shortcuts:
Ctrl-O: Move Window to next screen
Mod4 + Control + j/k: Focus next/previous screen

reveal.js-Shortcuts:
o: Öffne Übersicht
s: Öffne Vortragsmonitor
-->

## Themenabend: NixOS 

**Slides:** https://github.com/Mic92/themenabend-nixos

28. April 2017

<img class="plain" src="nixos.png" height="150" width="150"></img>

Note:
- Ich Nixpkgs maintainer


## Das Nix-Projekt

- Nix: das System zur funktionalen Verwaltung von Paketen (package management) mit einer eigenen dafür verwendeten Sprache zum Bauen von Paketen<img style="float: right" class="plain" src="topologie.svg"></img>
- Nixpkgs: die Sammlung von Paketen, die mit Nix verwaltet werden können
- NixOS: die auf Nix basierende Distribution (für die Verwendung von Linux)
- Hydra: ein auf Nix basiertes System zum verteilten Bauen von Paketen (CI)
- NixOps: ein auf NixOS basiertes Werkzeug für das Einrichten von Instanzen

Note:
- Nix: Edolstra, 2006
- nixpkgs: ähnlich Ports


## Besonderheiten von Nix

- *generisch:* sprach- und technologieagnostisch
- *reproduzierbar:* selbe Eingabe führt zur selben Ausgabe
- *verlässlich:* alle Abhängigkeiten sind vollständig: atomare Aktualisierungen und mögliches Zurückwechseln (Rollbacks)
- *effizient:* nur notwendig Schritte für Aktualisierungen

Note:
- reproduzierbar: keine Wechselwirkungen zwischen Paketen
- atomar: vorherige Stände bleiben erhalten
- effizient: beim Neubauen und Aktualisieren von Paketen


## NixOS - Konfiguration

```nix
# /etc/nixos/configuration.nix
{ pkgs, ... }:
{ 
  boot.loader.grub.device = "/dev/sda";
  fileSystems = [ { mountPoint = "/"; device = "/dev/sda2"; } ];
  swapDevices = [ { device = "/dev/sda1"; } ];
  services = {
    openssh.enable = true;
    xserver = {
      enable = true;
      desktopManager.kde4.enable = true;
    };
  };
  environment.systemPackages = [ pkgs.mc pkgs.firefox ];
}
```

Note:
- syntax highlighting! 
- Funktion (Nix expression language)


## NixOS - Konfiguration

```console
$  nixos-rebuild switch
```

1. Baut Konfiguration + startet/stoppt Dienste
2. Upgrades sind atomar
3. Nutzer kann zu alten Generationen zurück

Note:
- eine Möglichkeit upzudaten (setzt Bootloader)
- Packete + Konfiguration sind in Sync 
- garbage collection


## NixOS Grub

<img class="plain" src="nixos-grub.png"></img>


## Nix - der Packetmanager

<img class="plain" src="topologie-2.svg"></img>


## Nix - Funktionsweise

- Idee: Alle packages werden isoliert voneinander:
- `/nix/store/rpdqx...-firefox-3.5.4`
- Pfad enhält einen 160-bit kryptografischen Hash aller Packetabhängigkeiten:
  - Quellen, Bibliotheken, Kompiler, Buildskripte


## Nix - Funktionsweise
```
/nix/store 
|-- l9w6773m1msy...-openssh-4.6p1
|  |-- bin
|  |  |-- ssh
|  |-- sbin
|     |-- sshd
|-- smkabrbibqv7...-openssl-0.9.8e
|  |-- lib
|     |-- libssl.so.0.9.8
|-- c6jbqm2mc0a7...-zlib-1.2.3
|  |-- lib
|     |-- libz.so.1.2.3
|-- im276akmsrhv...-glibc-2.5
   |-- lib
      |-- libc.so.6
```


## Nix - Funktionsweise

Bei der Installation wird ein globale Profil mit Symlinks erstellt:

```console
$ which which
/run/current-system/sw/bin/which
$ readlink -f /run/current-system/sw/bin/which                                                              
/nix/store/fnrf1bns...-which-2.21/bin/which
$ ldd /run/current-system/sw/bin/which
linux-vdso.so.1
libc.so.6 => /nix/store/78w6a8zinhp...-glibc-2.25/lib/libc.so.6
/nix/store/78w6a8zin...-glibc-2.25/lib/ld-linux-x86-64.so.2
```


## Nix - Funktionsweise

Bei einem Update wird eine neue Generation erstellt,

```console
$ readlink /nix/*/profiles/system
system-417-link
$ readlink /nix/*/profiles/system-417-link/sw/bin/which
/nix/store/fnrf1bnsz3..-which-2.21/bin/which
$ readlink /nix/var/nix/profiles/per-user/joerg/profile
profile-139-link
```

ältere Generationen bleiben bis sie garbage collected werden erhalten:

```console
$ nix-collect-garbage
```


## Nix - Expressions

```nix
# openssh.nix
{ stdenv, fetchurl, openssl, zlib }:
stdenv.mkDerivation {
  name = "openssh-4.6p1";
  src = fetchurl {
    url = http://.../openssh-4.6p1.tar.gz;
    sha256 = "0fpjlr3bfind0y94bk442x2p...";
  };
  buildCommand = ''
    tar xjf $src
    ./configure --prefix=$out --with-openssl=${openssl}
    make
    make install
 '';
}
```

Note:
- Reihenfolge wird erkannt
- automatisch runtime deps
- dev-output
- weiß wann neugebaut werden muss (keine maintainer revisions)


## Nix - Expressions

```nix
# all-packages.nix

openssh = import ../tools/networking/openssh {
  inherit fetchurl stdenv openssl zlib;
};
openssl = import ../development/libraries/openssl {
  inherit fetchurl stdenv perl;
};
stdenv = ...;
openssl = ...;
zlib = ...;
perl = ...;
```

```
$ nix-env -f all-packages.nix -iA openssh
/nix/store/l9w6773m1msy...-openssh-4.6p1
```

Note:
- lazy ausgewertet


## Nixpkgs 

- github.com/NixOS/nixpkgs
- \>13.000 Packete für x86_64 linux
- https://nixos.org/nixos/packages.html
- Abstraktionen für die meisten Buildsysteme
  - (\*alle\* Haskellpackete)
- Aktuelle unterstützte Platformen (Binärpackete)
  * Linux: i686, x86_64, (aarch64)
  * Mac OS X: x86_64


## nixpkgs/nixos

- NixOS ist Bestandteil von Nixpkgs
- 689 Module:
  - Systemeinstellungen (Zeitzone, Fonts, Benutzer)
  - Services (sshd, nginx, openstack, gitlab, ...)
- Stable- und Unstablechannel
- jährlich 2 x Release (17.03 -> 17.09)

Note:
- Stable und unstable (mischbar)


## Hydra

- Baut alle Packete
- selber betreibbar (Binary Cache)
<img class="plain" src="hydra.png" height="400px"></img>


## Praxisteil

Zwischenfragen?

<!--
- nixos 
- nix-shell
- nix shebang
- nixops

wo eigenet sich NixOS, wo nicht.
 -->
