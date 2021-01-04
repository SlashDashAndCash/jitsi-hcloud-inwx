#/bin/bash

PDIR=$(dirname $0)
PWD="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ "$PATH" != "$PWD"* ]]; then
  export PATH=$PWD/bin:$PATH
fi

sed "s|PROVIDER_DIR|$PWD/providers|g" ./.terraformrc.template > ./.terraformrc

export TF_CLI_CONFIG_FILE=$PWD/.terraformrc
