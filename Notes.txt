# /etc/nixos/configuration.nix

- openntpd
- https://nixos.org/nixos/options.html -> openntpd
- add services.openntpd.enable = true;
$ timedatectl
$ systemctl status systemd-timesyncd
$ sudo nixos-rebuild switch
-> stoppt systemd-timesyncd
-> started openntpd
$ systemctl status openntpd systemd-timesyncd
$ man nixos-rebuild
$ sudo nixos-rebuild build-vm
$ /nix/store/p075cgg2x0mxylpy42j1b7c37mfri2mw-nixos-vm/bin/run-turingmachine-vm

# doku ist ausbaubar - Codesuche!
https://nixos.org/nixos/packages.html -> silver
- add environment.systemPackages = [ pkgs.ripgrep ];
$ rg "grep ="

$ nix-env -f '<nixpkgs>' -iA ack
$ ack "fuck"
$ nix-env --uninstall ack

$ nix-shell -p platinum-searcher
$ pt "firefox ="
$ nix-shell -p platinum-searcher --command 'pt "firefox ="'

./nix-shebang-bash
./nix-shebang-python

$ cd ~/git/themenabend-nixos/c3d2-web
$ make -> fehler
$ cat default.nix
$ make
- http://localhost:2015/c3d2/news/ta-nixos.html


```
containers.db1 = {
  autoStart = true;

  config = { config, pkgs, ... }: {
    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "init.sql" ''
        CREATE ROLE "postgres" LOGIN;
      '';
    };
  };
};
```

$ sudo nixos-container status db1
$ sudo nixos-container root-login db1
db1> sudo -u postgres psql

$ cd ~/git/valauncher
$ nix-build

$ cd ~/git/themenabend-nixos/pry
$ nix-build

$ cd /etc/nixos
$ vim gce.nix
$ nixops ssh eva
$ nixops deploy
- https://monit.thalheim.io/
