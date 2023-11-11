#!/usr/bin/env bash
set -euEo pipefail
eval $(gcloud secrets versions access ${secret_version} --secret ${secret_name})

curl -s --form-string "token=$TOKEN" \
  --form-string "user=$USER_KEY" \
  --form-string "message=Yeah, I'm going down" \
  https://api.pushover.net/1/messages.json
