# Cluster

## Nodes

These are all the nodes in my home lab, all of them are running NixOS you can find their specific config
[here](https://gitlab.com/hmajid2301/dotfiles).

|   Hostname                                                                                                                                                    |            Board                                          |               CPU                                              |  RAM        |         Primary GPU        |
| :---------:                                                                                                                                                   | :-------------------------:                               | :----------------------------:                                 | :---:       | :-------------------------:|
| [`um790`](https://gitlab.com/hmajid2301/dotfiles/-/blob/main/systems/x86_64-linux/um790/default.nix?ref_type=heads)                                           |  UM790                                                    |  AMD Ryzen 9 7940HS                                            | 64GB        | AMD Radeon™ 780M           |
| [`ms01`](https://gitlab.com/hmajid2301/dotfiles/-/blob/main/systems/x86_64-linux/ms01/default.nix?ref_type=heads)                                             | Framework 12th Gen Intel                                  |  i9-13900H                                                     | 32GB        | Intel Iris Graphics        |
| [`s100`](https://gitlab.com/hmajid2301/dotfiles/-/blob/main/systems/x86_64-linux/s100/default.nix?ref_type=heads)                                             | Framework 12th Gen Intel                                  |  i7-1280P                                                      | 32GB        | Intel Iris Graphics        |

## Setup

This repository uses fluxcd for GitOps, to automatically deploy changes made to this repository on the main branch.

## Usage

> Note I copied the kube config file from the cluster and called it config.personal

```bash
git clone git@gitlab.com:hmajid2301/home-lab.git
cd home-lab
direnv allow

# Can load from an env file
GITLAB_TOKEN=deploy-token
flux bootstrap gitlab \
        --owner=hmajid2301 \
        --repository=home-lab \
        --branch=main \
        --path=clusters/ \
        --personal --deploy-token-auth
```
