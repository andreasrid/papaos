{ pkgs, ... }:

pkgs.testers.nixosTest {
  name = "systemd-email-notify";

  nodes = {

    mailserver =
      { pkgs, ... }:
      {
        users.users.alice = {
          isNormalUser = true;
          description = "Alice Foobar";
          password = "foobar";
          uid = 1000;
        };
        #imports = [ ../modules/systemd-email-notify.nix ];
        networking = {
          firewall.allowedTCPPorts = [
            25
            143
          ];
        };
        environment.systemPackages = [ pkgs.opensmtpd ];
        services.opensmtpd = {
          enable = true;
          extraServerArgs = [ "-v" ];
          serverConfiguration = ''
            listen on 0.0.0.0
            action dovecot_deliver mda \
              "${pkgs.dovecot}/libexec/dovecot/deliver -d %{user.username}"
            match from any for local action dovecot_deliver
          '';
        };
        services.dovecot2 = {
          enable = true;
          enableImap = true;
          mailLocation = "maildir:~/mail";
          protocols = [ "imap" ];
        };
      };

    client =
      { pkgs, ... }:
      {
        imports = [ ../modules/systemd-email-notify.nix ];

        systemd.email-notify = {
          enable = true;
          mailTo = "alice@mailserver";
          mailFrom = "client@mailserver";
        };

        programs.msmtp = {
          enable = true;
          accounts.default = {
            host = "mailserver";
            user = "alice";
            password = "foobar";
            from = "alice@mailserver";

          };
        };

        systemd.services.test-email-notify = {
          description = "Service file to test the Failure Notification System";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "false";
          };
        };

        environment.systemPackages =
          let
            checkMailLanded = pkgs.writeScriptBin "check-mail-landed" ''
              #!${pkgs.python3.interpreter}
              import imaplib
              import time

              def wait_for_mail(imap):
                 for i in range(5):
                    status, (count,) = imap.select()
                    total_messages = int(count)
                    assert status == 'OK'
                    if total_messages:
                       return True
                    time.sleep(0.1)

                 raise RuntimeError(f"Total number of messages in a INBOX {total_messages}")

              with imaplib.IMAP4('mailserver', 143) as imap:
                 imap.login('alice', 'foobar')

                 wait_for_mail(imap)
                 status, msg = imap.fetch('1', 'BODY[TEXT]')
                 assert status == 'OK'
                 content = msg[0][1]
                 print('Received Message: ' + str(content))
                 assert b'Service file to test the Failure Notification System' in content
            '';
          in
          [
            checkMailLanded
            pkgs.system-sendmail
          ];
      };
  };

  testScript = ''
    start_all()

    mailserver.wait_for_unit("opensmtpd")
    mailserver.wait_for_unit("dovecot2")

    # To prevent sporadic failures during daemon startup, make sure
    # services are listening on their ports before sending requests
    mailserver.wait_for_open_port(25)
    mailserver.wait_for_open_port(143)

    client.systemctl("start test-email-notify.service")
    mailserver.succeed("smtpctl schedule all")

    client.succeed("check-mail-landed")
  '';

  meta.timeout = 1800;
}
