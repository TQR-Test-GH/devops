#!/usr/bin/env bash
# Every Port callback the pipeline makes, in one place.
#
#   port.sh log   "<markdown>"    → append a line to the cluster's log property
#   port.sh patch '<json>'        → update the cluster entity
#   port.sh cr    CHG-x '<json>'  → update the change request
#
# Node status is reported by Port itself (the workflow's dispatch node sets
# reportWorkflowStatus: true), so the pipeline only enriches the entity.
#
# Needs: PORT_TOKEN, PORT_ENTITY
set -euo pipefail
API="${PORT_API:-https://api.getport.io/v1}"
AUTH=(-H "Authorization: Bearer $PORT_TOKEN" -H 'Content-Type: application/json')

case "$1" in
  log)
    OLD=$(curl -sS "$API/blueprints/k8s_cluster/entities/$PORT_ENTITY" "${AUTH[@]}" \
          | jq -r '.entity.properties.log // ""')
    curl -sS -X PATCH "$API/blueprints/k8s_cluster/entities/$PORT_ENTITY" "${AUTH[@]}" \
      -d "$(jq -n --arg l "$OLD- $2"$'\n' '{properties:{log:$l}}')" >/dev/null
    echo "→ $2"
    ;;
  patch)
    curl -sS -X PATCH "$API/blueprints/k8s_cluster/entities/$PORT_ENTITY" "${AUTH[@]}" -d "$2" >/dev/null
    ;;
  cr)
    curl -sS -X PATCH "$API/blueprints/change_request/entities/$2" "${AUTH[@]}" -d "$3" >/dev/null
    ;;
esac
