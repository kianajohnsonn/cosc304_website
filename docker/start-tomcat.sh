#!/usr/bin/env bash
set -euo pipefail

: "${PORT:=8080}"
CATALINA_HOME=${CATALINA_HOME:-/usr/local/tomcat}

SERVER_XML="$CATALINA_HOME/conf/server.xml"
if [[ -f "$SERVER_XML" ]]; then
  # Replace the default port="8080" with the runtime $PORT if present.
  # This is a simple textual replacement; it is fine for the default Tomcat server.xml.
  sed -ri "s/port=\"8080\"/port=\"${PORT}\"/g" "$SERVER_XML" || true
fi

exec "$CATALINA_HOME/bin/catalina.sh" "$@"
