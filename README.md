# jitsi-hcloud-inwx
Bootstraps a Jitsi Meet server. All you neeed is a Hetzner Cloud account and a domain hosted at INWX.

## Security considerations
This project installes a Jitsi Meet server as is. No authentication and access restrictions will be configured. \
If you're looking for advanced security settings. Take a look at https://jitsi.github.io/handbook/docs/devops-guide/secure-domain

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
3. Create a new token with read/write permission.

## Fill out input variables
`vi input.hcl` \
All uncommented variables are mandatory. Paste the newly created API-Token into hcloud_token.

## Bootstrap your server
1. Source environment script. This must be done in every new terminal session.
`. env.sh`
2. Run Terragrunt. This will upload your SSH pulic key and create server, Let's Encrypt certificate and DNS recdords.
```
. env.sh
cd terragrunt
terragrunt apply-all --terragrunt-non-interactive
```
Timeouts are 7 minutes for the certificate and 30 minutes to connect to the server. \
Keep in mind Jitsi Meet is **open to public** by default.

## Deleting the server
You may want to remove the Jitsi server to reduce costs. The Let's Encrypt certificate should never be destroyed.
```
. env.sh
export TG_PREVENT_DESTROY=false
cd terragrunt/jitsi
terragrunt destroy
cd ../dns
terragrunt destroy
cd ../server
terragrunt destroy
export TG_PREVENT_DESTROY=true
```

## Migrating the states
Moving to another workstation is easy. However every project dir on every workstation needs an unique Hetzner Cloud project and server (FQDN).
1. Backup your input.hcl and tf_state dir.
2. On your new workstation follow the *installation instructions*.
3. Restore input.hcl and tf_state dir.
4. Continue with *Bootstrap your server* section.
