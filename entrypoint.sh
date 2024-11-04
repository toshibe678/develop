#!/bin/bash

if [[ -z "${TERRAFORM_TOKEN}" ]]; then
  echo "no terraform_token"
else
  sed -i -e "s/TOKEN_KEY/${TERRAFORM_TOKEN}/g" /root/.terraformrc
fi

exec "$@"
