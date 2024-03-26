{ config, pkgs, lib, ... }:
{
  # Disable password authentication
  users.users.btrbk.hashedPassword = "*";

  # Run backup only manually. Instead of a daily backup use Systemd service to create snapshots only.
  # Replace 'run' with 'snapshot':
  systemd.services.btrbk-btrbk.serviceConfig.ExecStart = lib.mkForce "${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/btrbk.conf snapshot --preserve ${config.networking.hostName}";

  services.btrbk = {
    extraPackages = [ pkgs.lz4 ];
    instances.btrbk.settings = {
      stream_compress = "lz4";
      #transaction_log = "/var/log/btrbk.log";
      #lockfile = "/run/lock/btrbk.lock";
      snapshot_dir = ".snapshots";
      snapshot_create = "onchange";
      timestamp_format = "long";

      # Definition:
      # - hourly backup :: first backup of an hour is considered an hourly backup
      # - daily backup :: preserve_hour_of_day defines after what time (in full hours since midnight) a snapshot/backup is considered to be a "daily" backup (Default: 0)
      # - weekly backup :: preserve_day_of_week defines on what day a snapshot/backup is considered to be a "weekly" backup (Default: sundday)
      # - monthly backup :: Every first weekly backup in a month is considered a monthly backup.
      # - yearly backup :: Every first monthly backup in a year is considered a yearly backup.

      # keep all snapshots for 30 days, no matter how frequently you run btrbk
      snapshot_preserve_min = "30d";

      # keep yearly backups for 5 years
      # keep monthly backups for 24 months
      target_preserve = "24m 5y";
      # Amount of time (duration) in which all backups are preserved
      target_preserve_min = "6m";

      # keep 6 monthlys and all yearlies in archive
      # and all backups for 3 months, no matter how frequently you run btrbk
      #archive_preserve = "6m *y";
      #archive_preserve_min = "3m";
      archive_preserve_min = "latest";

      volume = {
        "/.btr_pool" = {
          target = "/run/btrbk/dst";
          group = "scorpion";

          subvolume = {
            "@home" = {};
            "@persistent" = { target_preserve_min = "latest"; };
          };
        };
      };
    };
  };
}
