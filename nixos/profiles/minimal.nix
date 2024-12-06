{ config, pkgs, ... }:
{
  imports = [
    ../flakes.nix
    ../security
    ../locale.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      rxvt_unicode.terminfo
      vim
      emacs
      lsof
      wget
      file
      binutils # ship command 'strings' required by lesspipe
      coreutils
      pciutils
      htop
      killall
      openssl
      inotify-tools
    ];

    # Don't bother with the lecture or the need to keep state about who's been lectured
    security.sudo.extraConfig = "Defaults lecture=\"never\"";

    programs.bash.promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        PROMPT_COLOR="1;31m"
        ((UID)) && PROMPT_COLOR="1;32m"
        if [ -n "$INSIDE_EMACS" ] || [ "$TERM" = "eterm" ] || [ "$TERM" = "eterm-color" ]; then
          # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
          PS1="\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
        else
          PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
        fi
        if test "$TERM" = "xterm"; then
          PS1="\[\033]2;\h:\u:\w\007\]$PS1"
        fi
      fi
    '';
  };
}
