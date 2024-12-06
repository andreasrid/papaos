{ config, lib, pkgs, ... }:

{
  sops.secrets."emailNotify/mailTo" = {};
  sops.secrets."emailNotify/mailFrom" = {};
  sops.secrets."emailNotify/smtpPassword" = {};

  systemd.email-notify = {
    enable = true;
    mailTo = "`cat ${config.sops.secrets."emailNotify/mailTo".path}`";
    mailFrom = "`cat ${config.sops.secrets."emailNotify/mailFrom".path}`";
  };

  programs.msmtp = {
    enable = true;
    accounts.default = {
      host = "mxe8e4.netcup.net";
      passwordeval = "cat ${config.sops.secrets."emailNotify/smtpPassword".path}";
    };
    extraConfig = ''
      auth on
      tls on
      tls_starttls off
      eval echo user $(cat ${config.sops.secrets."emailNotify/mailFrom".path})
      eval echo from $(cat ${config.sops.secrets."emailNotify/mailFrom".path})
    '';
  };
}
