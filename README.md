# Home Lab

This is a repository containing all the Kubernetes configuration related to my Home Lab.

- 1x UM790 Minis Forum
- 1x MS01 Minis Forum
- 1x SL100 Minis Forum

You can read more about how it is all setup on my [blog](https://haseebmajid.dev/series/setup-raspberry-pi-cluster-with-k3s-and-nixos/).
You can find a list of how these devices are [set up using Nix](https://github.com/hmajid2301/dotfiles).

This repository uses Flux CD for Git Ops, to automatically deploy changes made to this repository on the main branch.
You can read more about my [home lab in the docs](https://docs.homelab.haseebmajid.dev).

## Features

- Automated, reproducible, setup through using NixOS (in another repo).
- Encrypted secrets with SOPS and Age
- SSL certificates from Cloudflare and cert-manager
- Using longhorn for persistent storage management
- All apps protected with authentication using Authentik.
- Tailscale (in dotfiles repo) and Twingate for managing access.
<!-- - Integrated GitHub Actions -->
<!-- - Web application firewall provided by Cloudflare Tunnels -->
<!-- - Next-gen networking using Cilium -->
<!-- - A Renovate-ready repository with pull request diffs provided by flux-local -->
<!-- - Opinionated implementation of Flux from the Home Operations Community's template -->

## Usage

> Note I copied the kube config file from the cluster and called it config.personal

```bash
git clone git@gitlab.com:hmajid2301/homelab.git
cd homelab
direnv allow

# To force a reconcile with the git repo
flux reconcile  source git flux-system

```

## System Configuration

Each device is configured and runs NixOS, you can find their specific configuration [here](https://gitlab.com/hmajid2301/dotfiles).
## Images

![Rack](docs/images/rack.jpg)
![Dashboard](docs/images/dashboard.png)

## More Information

- Hosts Managed by Nix: https://gitlab.com/hmajid2301/dotfiles
- Blog Post: https://haseebmajid.dev/posts/2023-11-18-how-i-setup-my-raspberry-pi-cluster-with-nixos/

