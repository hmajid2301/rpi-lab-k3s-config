{pkgs, ...}: let
  hostname = "one";
in {
  networking = {
    hostName = hostname;
  };

  nix.settings.trusted-users = [hostname];

  users = {
    users."${hostname}" = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = ["wheel"];
      password = hostname;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuM4bCeJq0XQ1vd/iNK650Bu3wPVKQTSB0k2gsMKhdE hello@haseebmajid.dev"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINP5gqbEEj+pykK58djSI1vtMtFiaYcygqhHd3mzPbSt hello@haseebmajid.dev"
      ];
    };
  };
}