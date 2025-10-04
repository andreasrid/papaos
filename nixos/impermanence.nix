{ config, lib, pkgs, impermanence, ... }:

with lib;
let
  cfg = config.environment.impermanence;
in
{
  imports = [
    impermanence.nixosModules.impermanence
  ];

  options.environment.impermanence = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable clean root mount.
      '';
    };
    device = mkOption {
      default = null;
      type = types.nullOr types.path;
      description = ''
        Location of the device used for a clean root '/'.
      '';
    };
    subvolume = mkOption {
      default = "@";
      type = types.nullOr types.str;
      description = ''
        Name of the Btrfs subvolume mounted at '/'.
      '';
    };

    extraMountOptions = mkOption {
      default = [ "compress-force=zstd" "noatime" ];
      type = with types; nonEmptyListOf str;
      description = ''
        Extra Mount options.
      '';
    };

  };

  config = mkIf cfg.enable {
    fileSystems."/" = {
      device = cfg.device;
      fsType = "btrfs";
      options = [ "subvol=${cfg.subvolume}" ] ++ cfg.extraMountOptions;
    };

    fileSystems."/persistent" = {
      device = cfg.device;
      neededForBoot = true;
      fsType = "btrfs";
      options = [ "subvol=@persistent" ] ++ cfg.extraMountOptions;
    };

    boot.initrd.postDeviceCommands = lib.mkAfter ''
      function pause(){
        read -s -n 1 -p "Press any key to continue ..."
        echo
      }
      mkdir /btrfs_tmp
      mount ${cfg.device} /btrfs_tmp
      if [[ -e /btrfs_tmp/${cfg.subvolume} ]]; then
        mkdir -p /btrfs_tmp/${cfg.subvolume}_old
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/${cfg.subvolume})" "+%Y-%m-%-d_%H:%M:%S")
        mv "/btrfs_tmp/${cfg.subvolume}" "/btrfs_tmp/${cfg.subvolume}_old/$timestamp" || pause
      fi

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done

        if [[ "$1" == "/btrfs_tmp/${cfg.subvolume}_old/*" ]]; then
          btrfs subvolume delete "$1" || pause
        else
          echo "ERROR: subvolume \'$1\' out of range"
          pause
        fi
      }

      for i in $(find "/btrfs_tmp/${cfg.subvolume}_old/" -mindepth 1 -maxdepth 1 -mtime +180); do
        delete_subvolume_recursively "$i"
      done

      btrfs subvolume create "/btrfs_tmp/${cfg.subvolume}" || pause
      umount /btrfs_tmp
    '';
    #environment.etc = {
      #"group".source = "/persistent/etc/group";
      #"passwd".source = "/persistent/etc/passwd";
    #  "shadow".source = "/persistent/etc/shadow";
    #};

    environment.persistence."/persistent" = {
      hideMounts = true;
      directories = [
        "/var/spool"
        #"/var/cache/containers"
        #"/var/lib/docker"
        #"/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/alsa"
        "/var/lib/systemd"
        "/etc/ssh"
        "/etc/NetworkManager/system-connections"
        { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }

        # Keep DHCP Client Identifier, otherwise we will receive a new IP address after each reboot
        "/var/db/dhcpcd"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

}
