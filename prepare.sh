#!/bin/bash

set -e

validate () {
  CHECKSUM=$(sha256sum $1)
  [[ "$CHECKSUM" == "$2"* ]] && echo true || echo false
}

download_file () {
  FILE=$1

  [[ -f $FILE ]] || curl -q -L -o $FILE $2


  if [[ $(validate $FILE $3) == false ]]; then
    rm -f $FILE
    echo "WARN: Checksum of $FILE doesn't match. Trying to download again"
    curl -q -L -o $FILE $2

    if [[ $(validate $FILE $3) == false ]]; then
      echo "ERROR: Checksum of $FILE doesn't match"
      exit 1
    fi
  fi

  if [[ $FILE == *".zip" ]]; then
    unzip -q -o $FILE -d $(dirname $FILE)
    FILE=${FILE%".zip"}
  fi

  chmod +x $FILE
}


ARCH=$(uname -m)
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$ARCH" == "x86_64" ]]; then
  FLAVOUR='linux_amd64'

  TERRAFORM_VERSION='0.14.3'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='aa7b6cb6f366ffb920083b2a9739079ee560240ca31b580fe422af4af28cbb5a'

  TERRAGRUNT_VERSION='v0.26.7'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='ac9df2de05d8fd14e3f8deb91899814461ac89f9cecb6a1fb44c8e74e1c6bf06'

  INWXPROVIDER_VERSION='v0.3.0'
  INWXPROVIDER_URL="https://github.com/andrexus/terraform-provider-inwx/releases/download/$INWXPROVIDER_VERSION/${FLAVOUR}_terraform-provider-inwx"
  INWXPROVIDER_CHECKSUM='67e3ea767bf9202a070b83448a351d17d1e27bc59fb1952e9c6706e6ec0bc9b6'
elif [[ "$OSTYPE" == "darwin"* ]] && [[ "$ARCH" == "x86_64" ]]; then
  FLAVOUR='darwin_amd64'

  TERRAFORM_VERSION='0.14.3'
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_${FLAVOUR}.zip"
  TERRAFORM_CHECKSUM='eda23614cd1dce1e96e7adf84f445c2783132c072fbd987f1f8858f34c361e41'

  TERRAGRUNT_VERSION='v0.26.7'
  TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_${FLAVOUR}"
  TERRAGRUNT_CHECKSUM='6ab96b0575165d432c213cc8a7678d7384763a7cf16db413bdce3c039bb0af35'

  INWXPROVIDER_VERSION='v0.3.0'
  INWXPROVIDER_URL="https://github.com/andrexus/terraform-provider-inwx/releases/download/$INWXPROVIDER_VERSION/${FLAVOUR}_terraform-provider-inwx"
  INWXPROVIDER_CHECKSUM='b18e342b9bd5792f2eaa226ddc86d62b97fb5b0ba996b5957126f957fb0d2614'
else
  echo "ERROR: Platform $ARCH - $OSTYPE not supported"
  exit 1
fi

PDIR="$(dirname $0)"
PWD="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "$PDIR"

[[ -d ./bin ]] || mkdir ./bin

[[ -d ./tf_state ]] || mkdir ./tf_state
chmod 0700 ./tf_state

download_file "./bin/terraform.zip" $TERRAFORM_URL $TERRAFORM_CHECKSUM

download_file "./bin/terragrunt" $TERRAGRUNT_URL $TERRAGRUNT_CHECKSUM

INWXPROVIDER_BIN=./providers/terraform.local/inwx/inwx/${INWXPROVIDER_VERSION#v}/$FLAVOUR/terraform-provider-inwx
[[ -d $(dirname $INWXPROVIDER_BIN) ]] || mkdir -p $(dirname $INWXPROVIDER_BIN)
download_file $INWXPROVIDER_BIN $INWXPROVIDER_URL $INWXPROVIDER_CHECKSUM

chmod +x ./env.sh

if [[ ! -f ./input.hcl ]]; then
  cp ./input.hcl.template ./input.hcl
  echo -e "\n\n*** Please fill out input.hcl ***\n\n"
fi
chmod 0600 ./input.hcl
