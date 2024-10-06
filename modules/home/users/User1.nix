{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.User1;
in {
  imports = [
    inputs.home-manager.nixosModules.default
  ];
  options.User1 = {
    enable = lib.mkEnableOption "Enable User1";
    username = lib.mkOption {
      default = "User1";
    };
    extraPkgs = lib.mkOption {
      default = [];
    };
    enableHomeManager = lib.mkOption {
      default = true;
    };

    isVM = lib.mkOption {
      description = "Wether the user is intended for server use or not (if enabled some packages will not be installed)";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."${cfg.username}" = {
      isNormalUser = true;
      description = "${cfg.username}";
      extraGroups = lib.mkDefault ["networkmanager" "wheel"];
      initialPassword = "a";
    };

    home-manager = lib.mkIf cfg.enableHomeManager {
      # also pass inputs to home-manager modules
      extraSpecialArgs = {inherit inputs;};
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";

      users."${cfg.username}" = {
        home.stateVersion = "23.11"; # Please read the comment before changing.

        home.packages = with pkgs; lib.mkDefault [
          cowsay
        ] ;

        programs = lib.mkDefault {
          # Let Home Manager install and manage itself.
          home-manager.enable = true;

          # zsh = {
          #   enable = true;
          #   enableCompletion = true;
          #   autosuggestion.enable = true;
          #   syntaxHighlighting.enable = true;
          #   dotDir = ".config/zsh";

          #   history.size = 10000;
          #   history.path = "${config.xdg.dataHome}/zsh/history";

          #   plugins = [
          #     {
          #       name = "powerlevel10k";
          #       src = pkgs.zsh-powerlevel10k;
          #       file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          #     }
          #     {
          #       name = "powerlevel10k-config";
          #       src = ./p10k-config;
          #       file = "p10k.zsh";
          #     }
          #   ];

          #   oh-my-zsh = {
          #     enable = true;
          #     plugins = ["git" "sudo" "colored-man-pages" "direnv"];
          #   };
          # };
        };
      };
    };
  };
}
