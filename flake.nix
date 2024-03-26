{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-23.11;
    nur.url = github:nix-community/NUR;
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = github:nix-community/home-manager/release-23.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, home-manager, sops-nix, impermanence, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      nur-no-pkgs = import nur {
        nurpkgs = import nixpkgs { system = "x86_64-linux"; };
      };

      my-overlays =
        let
          path = ./overlays;
        in
          map (e: import "${path}/${e}")
            (builtins.filter (n: builtins.match ".*\\.nix" n != null
                                 || builtins.pathExists (path + ("/" + n + "/default.nix")))
              (builtins.attrNames (builtins.readDir path)));

    in {
      nixosConfigurations.scorpion = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;

        modules = [
          ./hosts/scorpion/configuration.nix
          ./config/profiles/desktop.nix
          ./config/btrbk.nix
          ./config/xfce.nix
          ./config/security/pam-u2f.nix
          ./config/users/root
          ./config/users/hermann
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          {
            nixpkgs.overlays = my-overlays ++ [
              nur.overlay
            ];
            networking = {
              hostName = "scorpion";
            };

            services.openssh = {
              enable = true;
              settings = {
                PermitRootLogin = "yes";
              };
            };

            services.xserver.displayManager.autoLogin = {
              enable = true;
              user = "hermann";
            };
          }
        ];
      };

      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;

        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
          ./config/profiles/desktop.nix
          ./config/xfce.nix
          ./config/security/pam-u2f.nix
          ./config/users/hermann
          {
            nixpkgs.overlays = my-overlays ++ [
              nur.overlay
            ];
          }
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          {
            services.xserver.displayManager.autoLogin = {
              enable = true;
              user = "hermann";
            };

            services.openssh = {
              enable = true;
              settings = {
                PermitRootLogin = "yes";
                PermitEmptyPasswords = "yes";
              };
            };
            security.pam.services.sshd.allowNullPassword = true;
            services.getty.autologinUser = "root";
            users.users.root.hashedPassword = "";

            virtualisation.diskSize = 300 * 1024;
            networking = {
              hostName = "vm";
            };
          }
        ];
      };

      checks.x86_64-linux = {
        systemd-email-notify = import ./tests/systemd-email-notify.nix { inherit pkgs; };
      };
    };
}
