{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-24.05;
    nur.url = github:nix-community/NUR;
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = github:nix-community/home-manager/release-24.05;
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
          ./nixos/profiles/desktop.nix
          ./nixos/btrbk.nix
          ./nixos/auto-upgrade.nix
          ./nixos/xfce.nix
          ./nixos/security/pam-u2f.nix
          ./nixos/users/root
          ./nixos/users/hermann
          ./nixos/security/monitoring.nix
          ./modules/systemd-email-notify.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          {
            sops = {
              defaultSopsFile = ./hosts/scorpion/secrets.yaml;
              age.sshKeyPaths = [ "/persistent/etc/ssh/ssh_host_ed25519_key" ];
            };

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

            services.displayManager.autoLogin = {
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
          ./nixos/profiles/desktop.nix
          ./nixos/xfce.nix
          ./nixos/security/pam-u2f.nix
          ./nixos/users/hermann
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
            services.displayManager.autoLogin = {
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
