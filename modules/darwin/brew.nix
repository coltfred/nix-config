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
      "homebrew/cask-fonts"
      "homebrew/core"
      "homebrew/services"
      "homebrew/cask-drivers" # for flipper zero
      "fujiapple852/trippy"
    ];

    casks = [
      "amethyst" # for window tiling -- I miss chunkwm but it's successor, yabai, was unstable.
      "discord"
      "docker"
      "firefox"
      "insomnia"
      "imageoptim"
      "qlmarkdown"
      "raycast"
      "signal"
      "spotify"
      "zoom"
      "google-chrome"
      "steam"
      "gpg-suite"
    ];

    masApps = {
      "Keynote" = 409183694;
      "Slack" = 803453959;
      "Xcode" = 497799835;
    };
    brews = [ "pam-reattach" "chkrootkit" "trippy"];
  };
}
