#!/bin/bash

PDIR=$(dirname $0)
PWD="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ "$PATH" != "$PWD"* ]]; then
  export PATH=$PWD/bin:$PATH
fi

