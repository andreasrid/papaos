{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.systemd.email-notify;

  sendmail = pkgs.writeScript "sendmail" ''
    #!/bin/sh

    ${pkgs.system-sendmail}/bin/sendmail -t <<ERRMAIL
    To: ${config.systemd.email-notify.mailTo}
    From: ${config.systemd.email-notify.mailFrom}
    Subject: Status of service $1
    Content-Transfer-Encoding: 8bit
    Content-Type: text/plain; charset=UTF-8

    $(systemctl status --full "$1")
    ERRMAIL
  '';
in
{
  options = {
    systemd.email-notify = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Systemd Service Failure Notification System.
        '';
      };

      mailTo = mkOption {
        type = types.str;
        default = null;
        description = "Email address to which the service status will be mailed.";
      };

      mailFrom = mkOption {
        type = types.str;
        default = null;
        description = "Email address from which the service status will be mailed.";
      };
    };

    systemd.services = mkOption {
      type =
        with types;
        attrsOf (submodule {
          config.onFailure = [ "email-notify@%n.service" ];
        });
    };
  };

  config = mkIf cfg.enable {
    systemd.services."email-notify@" = {
      description = "Sends a status mail via sendmail on service failures.";
      onFailure = mkForce [ ];
      serviceConfig = {
        ExecStart = "${sendmail} %i";
        Type = "oneshot";
      };
    };
  };

}
