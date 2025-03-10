{
  pkgs,
  config,
  username,
  nixpkgs,
  ...
}: {
  time.timeZone = "America/Denver";
  # Fixes error about home dir being /var/empty
  # See https://github.com/nix-community/home-manager/issues/4026
  users.users.${username} = {
    home =
      if pkgs.stdenvNoCC.isDarwin
      then "/Users/${username}"
      else "/home/${username}";
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  # environment setup
  environment = {
    etc = {
      nixpkgs.source = "${nixpkgs}";
    };
    # list of acceptable shells in /etc/shells
    shells = with pkgs; [bash zsh];
    pathsToLink = ["/libexec"];
  };

  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = {
      # Because macos sandbox can create issues https://github.com/NixOS/nix/issues/4119
      sandbox = !pkgs.stdenv.isDarwin;
      trusted-users = ["${username}" "root" "@admin" "@wheel"];
      max-jobs = 8;
      cores = 0; # use them all
      allowed-users = ["@wheel"];
    };
    #autoOptimiseStore = true;
    #optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  imports = [
    ./pam.nix # enableSudoTouchIdAuth is now in nix-darwin, but without the reattach stuff for tmux
    ./core.nix
    ./brew.nix
    ./preferences.nix
  ];
}
