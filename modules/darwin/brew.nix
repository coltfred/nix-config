{ inputs, config, pkgs, ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup =
        "uninstall"; # should maybe be "zap" - remove anything not listed here
    };
    global = { brewfile = true; };

    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
      "fujiapple852/trippy"
    ];

    casks = [
      "amethyst" # for window tiling -- I miss chunkwm but it's successor, yabai, was unstable.
      "blackhole-2ch" # for recording output from speakers
      "discord"
      "docker-desktop"
      "firefox"
      "focusrite-control"
      "gpg-suite"
      "google-chrome"
      "insomnia"
      "imageoptim"
      "linearmouse"
      "qlmarkdown"
      "signal"
      "spotify"
      "steam"
      "zoom"
    ];

    masApps = {
      "Keynote" = 409183694;
      "Slack" = 803453959;
      "Xcode" = 497799835;
    };
    brews = [ "pam-reattach" "chkrootkit" "trippy" "gh"];
  };
}
