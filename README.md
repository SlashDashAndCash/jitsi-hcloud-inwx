# jitsi-hcloud-inwx
Bootstraps a Jitsi Meet server. All you neeed is a Hetzner Cloud account and a domain hosted at INWX.

## Security considerations
This project installes the Debian package jitsi-meet as is. No authentication and access restrictions will be configured. \
If you're looking for advanced security settings, take a look at https://jitsi.github.io/handbook/docs/devops-guide/secure-domain

The certificate and it's private key will be stored in the tf_state dir on your workstation.

## Prerequisites
- Linux or Darwin workstation to run Terraform on. \
Windows may also work but not tested.
- Git installed
- SSH keypair (defaults to ~/.ssh/id_rsa, ~/.ssh/id_rsa.pub)
- [Hetzner account](https://www.hetzner.com/)
- A domain hosted at [INWX](https://www.inwx.de/)

## Installation
1. Clone this project in your home directory (or any subfolder) \
`git clone https://github.com/SlashDashAndCash/jitsi-hcloud-inwx.git`
2. Run ./prepare script. This should be done only once.
```
cd jitsi-hcloud-inwx
chmod +x prepare.sh
./prepare.sh
```

## Create new Hetzner Cloud project
1. Open [Cloud Console](https://console.hetzner.cloud/projects) and add a new project.
2. Click into your new project and go to Security -> API-Tokens.
3. Create a new token with read/write permissions.

## Fill out input variables
`vi input.hcl` \
All uncommented variables are mandatory. Paste the newly created API-Token into hcloud_token.

## Bootstrap your server
1. Source environment script. This must be done in every new terminal session. \
`. env.sh`
2. Run Terragrunt. This will upload your SSH pulic key and create server, Let's Encrypt certificate and DNS records.
```
. env.sh
cd terragrunt
terragrunt apply-all --terragrunt-non-interactive
```
Timeouts are 7 minutes for the certificate and 30 minutes to connect to the server. \
Keep in mind Jitsi Meet is **open to public** by default.

## Deleting the server
You may want to remove the Jitsi server to reduce costs. The Let's Encrypt certificate should never be destroyed. \
A good aproach is to destroy the dns resource with dependencies. This will delete dns, server and ssh_key but not the cert.
```
. env.sh
cd terragrunt/dns
terragrunt destroy-all
```

To recreate the server, just follow the instructions in *Bootstrap your server*.

If you realy want to destroy the cert, you have to set the TG_PREVENT_DESTROY EnvVar.
```
. env.sh
cd terragrunt/cert
export TG_PREVENT_DESTROY=false
terragrunt destroy
export TG_PREVENT_DESTROY=true
```
Please note Terraform will keep a backup in tf_state/cert/terraform.tfstate.backup

## Migrating the states
Moving to another workstation is easy. However the tf_state dir must only exist at one single place.
1. Backup your input.hcl and tf_state dir.
2. On your new workstation follow the *installation instructions*.
3. Restore input.hcl and tf_state dir.
4. Continue with *Bootstrap your server* section.
