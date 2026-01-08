{ config, pkgs, ... }:

{
  # Allow unfree packages (needed for google-chrome)
  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # The home.packages option allows you to install Nix packages into your environment
  home.packages = with pkgs; [
    (fcitx5-with-addons.override { addons = [ fcitx5-mozc ]; })
    awscli2
    cask
    claude-code
    cmake
    cmigemo
    curl
    delve
    docker-compose
    dunst
    emacsPackages.mozc
    fcitx5-gtk
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
    guake
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
    wget

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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx5";
    QT_IM_MODULE = "fcitx5";
    XMODIFIERS = "@im=fcitx5";
  };

  # Prepend Nix profile to PATH
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
  ];

  # User services
  systemd.user.services = {
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
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.fcitx5-with-addons.override { addons = [ pkgs.fcitx5-mozc ]; }}/bin/fcitx5";
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
