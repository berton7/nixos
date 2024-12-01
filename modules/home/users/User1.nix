{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.User1;

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
  imports = [
    inputs.home-manager.nixosModules.default
  ];
  options.User1 = {
    enable = lib.mkEnableOption "Enable User1";
    username = lib.mkOption {
      default = "User1";
    };
    defaultPkgs = lib.mkOption {
      default = with pkgs; [
        # zsh shell
        zsh
        zsh-powerlevel10k
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.meslo-lg

        # other programs
        python3
        vscode-fhs
        spotify
        libsForQt5.kdeconnect-kde
      ];
    };
    extraPkgs = lib.mkOption {
      default = [];
    };
  };

  config = {
    users.users."${cfg.username}" = {
      isNormalUser = true;
      description = "${cfg.username}";
      extraGroups = lib.mkDefault ["networkmanager" "wheel"];
    };

    home-manager = {
      # also pass inputs to home-manager modules
      extraSpecialArgs = {inherit inputs;};
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";

      users."${cfg.username}" = {
        # allow unfree also in home-manager
        nixpkgs.config.allowUnfree = true;

        home.stateVersion = "23.11"; # Please read the comment before changing.

        home.packages = cfg.defaultPkgs ++ cfg.extraPkgs;

        home.file = {
          ".local/share/konsole/zsh.profile".text = "
            [Appearance]
            ColorScheme=DarkPastels

            [General]
            Command=zsh -l
            Name=zsh
            Parent=FALLBACK/
          ";
        };

        home.sessionVariables = {
          EDITOR = "nvim";
          NIXOS_CONFIG_ROOT = "$HOME/nixos";
        };

        programs = {
          home-manager = {
            enable = true;
          };

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
            dotDir = "$HOME/.config/zsh";

            shellAliases = commonAliases;
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
      };
    };
  };
}
