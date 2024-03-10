# packer-proxmox-ubuntu-server

With this Packer template for Proxmox you can build your custom ubuntu server virtual machine images.

## Requirements

* Proxmox VE 7.4.x server
* Create a proxmox api token
* Save proxmox credentials to a file
* Have network connectivity to/from proxmox server

## Create credentials file

After cloning this repo, create the file `credentials.pkr.hcl` in the root of the repo with this content:

```shell
proxmox_api_url = "https://proxmox-7:8006/api2/json"
proxmox_api_token_id = "root@pam!packer-token"
proxmox_api_token_secret = "packer-api-token-secret"
proxmox_node = "proxmox-7"
packer_runner_host = "127.0.0.1"
```

**IMPORTANT:** These values are only for example, use your own values, and never commit this file to the repo.

**IMPORTANT:** The IP address used for `packer_runner_host` should be one that is reachable by HTTP from
the proxmox server.

## Create focal template

Change to the `ubuntu-server-focal` directory and initialice the plugins:

```shell
packer init packer.pkr.hcl
```

Make these changes:

* Edit `ubuntu-server-focal.pkr.hcl` and change `PASSWORD_PLAIN` with your own value.
* Edit `http/user-data` and change `PASSWORD_HASH` with your own value.

Validate the changes:

```shell
packer validate ubuntu-server-focal.pkr.hcl
```

To build a ubuntu server image with focal release run packer with your variables file:

```shell
packer build -var-file=../credentials.pkr.hcl ubuntu-server-focal.pkr.hcl
```

## Create jammy template

Change to the `ubuntu-server-jammy` directory, initialice the plugins and validate the code:

```shell
packer init packer.pkr.hcl
packer validate ubuntu-server-jammy.pkr.hcl
```

Make these changes:

* Edit `ubuntu-server-jammy.pkr.hcl` and change `PASSWORD_PLAIN` with your own value.
* Edit `http/user-data` and change `PASSWORD_HASH` with your own value.

Validate the changes:

```shell
packer validate ubuntu-server-jammy.pkr.hcl
```

To build a ubuntu server image with jammy release Run packer with your variables file:

```shell
packer build -var-file=../credentials.pkr.hcl ubuntu-server-jammy.pkr.hcl
```
