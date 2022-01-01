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

  TERRAFORM_VERSION='1.1.2'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='734efa82e2d0d3df8f239ce17f7370dabd38e535d21e64d35c73e45f35dfa95c'

  TERRAGRUNT_VERSION='v0.35.16'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='0404f0dfd2ab3b642dcf2c1c038d0bcbee256ee14a92d731a9ea0514f6cf47f4'

elif [[ "$OSTYPE" == "darwin"* ]] && [[ "$ARCH" == "x86_64" ]]; then
  FLAVOUR='darwin_amd64'

  TERRAFORM_VERSION='1.1.2'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='214da2e97f95389ba7557b8fcb11fe05a23d877e0fd67cd97fcbc160560078f1'

  TERRAGRUNT_VERSION='v0.35.16'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='838fbc06abd04861224a676077cf24eb6505ed2fbb89d23e25b93d30aad6a2fc'

  elif [[ "$OSTYPE" == "darwin"* ]] && [[ "$ARCH" == "arm64" ]]; then
  FLAVOUR='darwin_arm64'

  TERRAFORM_VERSION='1.1.2'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='39e28f49a753c99b5e2cb30ac8146fb6b48da319c9db9d152b1e8a05ec9d4a13'

  TERRAGRUNT_VERSION='v0.35.16'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='085a101da0d312960f74901c270b7e05ccf0f5b58ad58aa416a74ea9a5aa42a0'

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
