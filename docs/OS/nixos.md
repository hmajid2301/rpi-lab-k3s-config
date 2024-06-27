# NixOS

All of my servers are running NixOS and their config is managed in a separated [repository](https://gitlab.com/hmajid2301/dotfiles).
This includes everything that needs to be managed by the nodes, such as how to partition the disks. What file system to
use. This also deploys k3s on each host.

## Why

NixOS is great, I am definitely a fanboy. It is great as it makes roll back straightforward if something goes wrong. In fact,
deploy-rs will roll back our config if a deployment makes the machine inaccessible, i.e. cannot ssh to it.

It also allows us to have our OS config in code, so it can be easily shared across my devices. I don't have to worry
about upgrades, as updates are never done in place.

There are other features I like such as the cool tooling, `nixos-anywhere`, `disko` and `deploy-rs` to make managing the
serves a lot easier.

### Example

An example which illustrates this pretty well is, each of my machines runs a Tailscale VPN. To install Tailscale all I had to do was add this line:

`services.tailscale.enable = true;`

Then Tailscale and the service is available on my machines. I could've gone further and made it authenticate with
Tailscale itself automatically. But because I rarely have to set this up, I just manually authenticated by running:
`sudo tailscale up`.

## Installation

Will install NixOS, assuming you can ssh to this machine, it will also partition the drives if you are using [Disko](https://github.com/nix-community/disko).

```bash
nixos-anywhere --flake '.#um790' nixos@192.168.1.6
```

## Deploy

We use [deploy-rs](https://github.com/serokell/deploy-rs) to deploy changes to our servers like so:

```bash
deploy .#um790 --hostname um790 --ssh-user nixos
```

So the very first time to set up the machine, nix-anywhere is used. Then any change after that, we use deploy-rs.

## Snowfall

I am using the [snowfall-lib](https://snowfall.org/guides/lib/systems/) "framework", which provides an opinionated way to structure your Nix configuration.
Looking at how other users structured their config. I noticed a lot of them used roles or archetype to re-use common
configuration. These would include configurations for say Desktops or servers.

Specifically for the Home Lab, I created some new roles for Kubernetes. The main advantage of this is to reduce boilerplate
in each system.

Where in my Nix config, each separate system gets its own folder with its own config.

```bash
systems/x86_64-linux
├── ms01
│  ├── default.nix
│  ├── disks.nix
│  └── hardware-configuration.nix
├── s100
│  ├── default.nix
│  ├── disks.nix
│  └── hardware-configuration.nix
└── um790
   ├── default.nix
   ├── disks.nix
   └── hardware-configuration.nix
```

### Structure

#### default. Nix

Is the main config, which looks something like:

```nix

{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  roles = {
    kubernetes = {
      enable = true;
      role = "agent";
    };
  };

  system.stateVersion = "23.11";
}
```

As you can see here, we're just enabling the Kubernetes role and then specifying that this "node" will act as an agent.

#### disks.nix

This file is used to partition the disk correctly. When we first deploy our configuration to the machine using nixos-anywhere.
It uses Disko to partition the drives. This means we can even declare how our disk should look in
code. Which is very cool, and improves reproducibility.

```nix

{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-L" "nixos" "-f"];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = ["subvol=home" "compress=zstd" "noatime"];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["subvol=persist" "compress=zstd" "noatime"];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = ["subvol=log" "compress=zstd" "noatime"];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "32G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
```

I have set these disks this way so that it can be used for [impermanence](https://github.com/nix-community/impermanence). I will write more about it when I get it working.
But essentially between boots, it will delete all files we don't specify we want to keep. Allowing us to treat us systems more like
cattle not pets,
[cattle vs pets](https://www.hava.io/blog/cattle-vs-pets-devops-explained).

#### hardware-configuration.nix

Generated by Nix, specific to each node certain kernel parameters to enable etc. It can be generated by running
`sudo -E -s nixos-generate-config --show-hardware-config --no-filesystems`. Then we can just copy the contents to this
file.
