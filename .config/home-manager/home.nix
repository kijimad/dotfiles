{ config, pkgs, ... }:

{
  # 非NixOS Linux用の設定
  targets.genericLinux.enable = true;

  # フォント設定
  fonts.fontconfig.enable = true;

  # Allow unfree packages (needed for google-chrome)
  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # Input method configuration
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # The home.packages option allows you to install Nix packages into your environment
  home.packages = with pkgs; [
    antimicrox
    arandr
    awscli2
    claude-code
    cmake
    cmigemo
    curl
    delve
    docker-compose
    dunst
    emacs.pkgs.cask
    emacsPackages.mozc
    font-awesome
    gemini-cli
    gh
    gimp
    git
    gnumake
    go
    gocode-gomod
    golangci-lint
    google-chrome
    gopls
    gotools
    # nix経由でインストールした場合、初期状態でなぜか変なフォントになる。手動で設定の「システムフォントを使う」を外して対応する
    guake
    imagemagick
    jq
    libtool
    libvterm
    mozc
    nodejs_24
    peco
    picom
    playerctl
    polybar
    postgresql
    python3
    qemu-utils
    qemu_kvm
    redshift
    ripgrep
    silver-searcher
    sqlite
    stow
    terraform
    tree
    typescript-language-server
    typora
    unetbootin
    vlc
    vscode
    wget
    yarn
    xournalpp

    # Custom Go packages
    (buildGoModule {
      pname = "gclone";
      version = "unstable-2025-10-07";
      src = fetchFromGitHub {
        owner = "kijimad";
        repo = "gclone";
        rev = "f3cf7fc1b24fcc5097e7c48afe7af535ee3f5bc2";
        hash = "sha256-CVRh8dAVhNR3ceynvGxhJqSrDpuR+bT/nw2Oux3yoDI=";
      };
      vendorHash = "sha256-w3jHXjA/nYOn4CWJFZDwfClFy+ZYv/HFIYeqlfydPhQ=";
    })
  ];


  # Prepend Nix profile to PATH
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
  ];

  # User services
  systemd.user.services = {
    # Home Manager switch on startup
    home-manager-switch = {
      Unit.Description = "Home Manager switch on startup";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.home-manager}/bin/home-manager switch";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

    # Swap Caps Lock and Control keys
    setxkbmap = {
      Unit.Description = "Set keyboard layout and swap Caps Lock with Control";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.xorg.setxkbmap}/bin/setxkbmap -option ctrl:swapcaps";
        RemainAfterExit = true;
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    syncthing = {
      Unit.Description = "Syncthing";
      Service = {
        ExecStart = "${pkgs.syncthing}/bin/syncthing --no-browser";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    redshift = {
      Unit.Description = "Redshift";
      Service = {
        ExecStart = "${pkgs.redshift}/bin/redshift";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    dunst = {
      Unit.Description = "Dunst notification daemon";
      Service = {
        ExecStart = "${pkgs.dunst}/bin/dunst";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    # picom = {
    #   Unit.Description = "Picom compositor";
    #   Service = {
    #     ExecStart = "${pkgs.picom}/bin/picom";
    #     Restart = "on-failure";
    #   };
    #   Install.WantedBy = [ "default.target" ];
    # };

    polybar = {
      Unit.Description = "Polybar status bar";
      Service = {
        ExecStart = "${pkgs.polybar}/bin/polybar top";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    fcitx5 = {
      Unit.Description = "Fcitx5 input method";
      Service = {
        ExecStart = "${pkgs.qt6Packages.fcitx5-with-addons.override { addons = [ pkgs.fcitx5-mozc pkgs.fcitx5-gtk ]; }}/bin/fcitx5";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };

    guake = {
      Unit.Description = "Guake drop-down terminal";
      Service = {
        ExecStart = "${pkgs.guake}/bin/guake";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  # SSH key generation
  home.activation = {
    generateSshKey = config.lib.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f ~/.ssh/id_ed25519 ]; then
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
      fi
    '';
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Emacs configuration
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
    extraPackages = epkgs: with epkgs; [
      mozc
    ];
  };

  # Git configuration
  programs.git = {
    enable = true;
  };
}
