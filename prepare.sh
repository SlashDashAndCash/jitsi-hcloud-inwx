#!/bin/bash

set -e

validate () {
  ARCH=$(uname -m)
  if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$ARCH" == "x86_64" ]]; then
    FLAVOUR='linux_amd64'
    CHECKSUM=$(sha256sum $1)
    [[ "$CHECKSUM" == "$2"* ]] && echo true || echo false
  elif [[ "$OSTYPE" == "darwin"* ]] && [[ "$ARCH" == "x86_64" ]]; then
    CHECKSUM=$(shasum -a 256 $1)
    [[ "$CHECKSUM" == "$2"* ]] && echo true || echo false
  elif [[ "$OSTYPE" == "darwin"* ]] && [[ "$ARCH" == "arm64" ]]; then
    CHECKSUM=$(shasum -a 256 $1)
    [[ "$CHECKSUM" == "$2"* ]] && echo true || echo false
else
  echo "ERROR: Platform $ARCH - $OSTYPE not supported" 1>&2
  exit 1
fi
}

download_file () {
  FILE=$1

  [[ -f $FILE ]] || curl -q -L -o $FILE $2

  if [[ $(validate $FILE $3) == false ]]; then
    rm -f $FILE
    echo "WARN: Checksum of $FILE doesn't match. Trying to download again" 1>&2
    curl -q -L -o $FILE $2

    if [[ $(validate $FILE $3) == false ]]; then
      echo "ERROR: Checksum of $FILE doesn't match" 1>&2
      exit 1
    fi
  fi

  if [[ $FILE == *".zip" ]]; then
    unzip -q -o $FILE -d $(dirname $FILE)
    FILE=${FILE%".zip"}
  else
    chmod +x $FILE
  fi
}


ARCH=$(uname -m)
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$ARCH" == "x86_64" ]]; then
  FLAVOUR='linux_amd64'

  TERRAFORM_VERSION='1.6.5'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='f6404dc264aff75fc1b776670c1abf732cfed3d4a1ce49b64bc5b5d116fe87d5'

  TERRAGRUNT_VERSION='v0.54.1'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='a7b6821ec91b6b6f5c6535e07ced1f503ff6bb588f418a1527cdddfc3272f118'

elif [[ "$OSTYPE" == "darwin"* ]] && [[ "$ARCH" == "x86_64" ]]; then
  FLAVOUR='darwin_amd64'

  TERRAFORM_VERSION='1.6.5'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='6595f56181b073d564a5f94510d4a40dab39cc6543e6a2c9825f785a48ddaf51'

  TERRAGRUNT_VERSION='v0.54.1'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='4c3461aca5e0fecdc9664193a9a2a9df030fdb089cd500e132ae3c0ece38515a'

  elif [[ "$OSTYPE" == "darwin"* ]] && [[ "$ARCH" == "arm64" ]]; then
  FLAVOUR='darwin_arm64'

  TERRAFORM_VERSION='1.6.5'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='5c66fdc6adb6e7aa383b0979b1228c7c7b8d0b7d60989a13993ee8043b756883'

  TERRAGRUNT_VERSION='v0.54.1'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='06f481b401a45340310c8d4fe4e0625ed5f69373075ed6cc9f2e1c36671f0417'

else
  echo "ERROR: Platform $ARCH - $OSTYPE not supported" 1>&2
  exit 1
fi

PDIR="$(dirname $0)"
PWD="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "$PDIR"

[[ -d ./bin ]] || mkdir ./bin

[[ -d ./tf_state ]] || mkdir ./tf_state
chmod 0700 ./tf_state

rm -rf terragrunt/*/.terragrunt-cache

download_file "./bin/terraform.zip" $TERRAFORM_URL $TERRAFORM_CHECKSUM

download_file "./bin/terragrunt" $TERRAGRUNT_URL $TERRAGRUNT_CHECKSUM

chmod +x ./env.sh

if [[ ! -f ./input.hcl ]]; then
  cp ./input.hcl.template ./input.hcl
  echo -e "\n\n*** Please fill out input.hcl ***\n\n"
fi
chmod 0600 ./input.hcl
