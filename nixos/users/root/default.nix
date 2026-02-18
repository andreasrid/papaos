{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.root = {
    # Move home directory from /root to /home/root
    # to eliminate BTRFS volume '@root'
    home = pkgs.lib.mkForce "/home/root";

    # The asterisk in the password hash prevent unix password authentication
    hashedPassword = "*";

    openssh.authorizedKeys.keys = [
      # Yubikey
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4gKiht22Vfw4OoW2V+++GR2OPb0ItOJNM/LTfAYeWdkcAntaPxQXVxsARIFPDAMUXtk9p59sqF1jq1RtVRRdmKR6pPVm0EQcW7/3RahIezIVu6rUHNVwvLvRuyLW93GUCUn51BSPHsNXnLN2snuZruYeyj8OUWXt25niX1/mHcWsOUSnyDkD9i5uhHyz/+oJ/VpjRsRvXPh1iYGWPEpuowPjjncQNu7V2e+LxSI+f2Y8hfdPMc/sYObPhr3zSx+jfINqv6qKBqxXaEiWgf5aOqO2gG5ZtBHSzcZa9Kwx+NCLD+MaLWpP0HOVy4+DO8s3ccFHpKIliBZDQZYb7ORI7 cardno:9 922 765"
    ];
  };
}
