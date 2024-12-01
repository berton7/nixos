{
  config,
  pkgs,
  ...
}: let
  # this is the directory of the final flake system configuration (/nix/store)
  storeDotfilesRoot = builtins.toString ../..;

  commonAliases = {
    # commands
    ls = "ls -hN --color=auto --group-directories-first";
    ll = "ls -lisa";
    mkd = "mkdir -pv";
    cl = "clear";
    grep = "grep --color=auto";
    diff = "diff --color=auto";
    ccat = "highlight --out-format=ansi";
    starts = "sudo systemctl start";
    stops = "sudo systemctl stop";
    restarts = "sudo systemctl restart";
    reloads = "sudo systemctl reload";
    stats = "sudo systemctl status";
    sudo = "sudo"; # alias under sudo
    dot = "code $NIXOS_CONFIG_ROOT";
    gu = "git undo";

    # scripts
    rs = "sudo nixos-rebuild switch --flake $NIXOS_CONFIG_ROOT";
    rt = "sudo nixos-rebuild test --flake $NIXOS_CONFIG_ROOT";
    rb = "dotfilesRoot=$NIXOS_CONFIG_ROOT ${storeDotfilesRoot}/nixos-rebuild.sh";
    nfu = "nix flake update $NIXOS_CONFIG_ROOT";
    up = "git -C $NIXOS_CONFIG_ROOT pull && nfu && rb";
    cleanup = "${storeDotfilesRoot}/cleanup.sh";

    # shell-nix
    mkshell = "cp ${storeDotfilesRoot}/modules/home/shell_default.nix shell.nix && chmod +w shell.nix && echo \"use nix\" > .envrc && direnv allow";
    mkflake = "cp ${storeDotfilesRoot}/modules/home/flake_default.nix flake.nix && chmod +w flake.nix && echo \"use flake\" > .envrc && direnv allow";
  };
in {
  # allow unfree also in home-manager
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "berton";
  home.homeDirectory = "/home/berton";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # zsh shell
    zsh
    zsh-powerlevel10k
    # (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "Meslo"];})
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.meslo-lg

    # other programs
    python3
    vscode-fhs
    spotify
    libsForQt5.kdeconnect-kde
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".local/share/konsole/zsh.profile".text = "
[Appearance]
ColorScheme=DarkPastels

[General]
Command=zsh -l
Name=zsh
Parent=FALLBACK/
";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/berton/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    NIXOS_CONFIG_ROOT = "$HOME/dotfiles/nixos";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = commonAliases;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";

      shellAliases = commonAliases;
      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = ../p10k-config;
          file = "p10k.zsh";
        }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = ["git" "sudo" "colored-man-pages" "direnv"];
      };
    };

    git = {
      enable = true;
      userName = "berton7";
      userEmail = "francy.berton99@gmail.com";
      extraConfig = {
        pull = {
          rebase = true;
        };
      };
      aliases = {
        undo = "reset HEAD~1 --soft";
      };
    };

    lazygit = {
      enable = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    htop = {
      enable = true;
      settings = {
        show_program_path = false;
      };
    };

    neovim = {
      enable = true;
      extraConfig = ''
        set number
      '';
    };
  };
}
