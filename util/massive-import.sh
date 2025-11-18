#!/bin/bash

# import-users.sh
# Uso:
#   ./import-users.sh /ruta/al/users.csv

if [ $# -ne 1 ]; then
  echo "Uso: $0 <archivo CSV>"
  exit 1
fi

CSV="$1"
TABLA="users"

SQL=$(cat <<EOF
COPY $TABLA (ext_id, data)
FROM PROGRAM \$\$
awk -F',' '{
  gsub(/\r/, "", \$0);

  ext_id=\$1;
  name=\$2;
  role=\$3;

  # Trim espacios
  gsub(/^ +| +$/, "", ext_id);
  gsub(/^ +| +$/, "", name);
  gsub(/^ +| +$/, "", role);

  # Generar JSON para columna data
  json = sprintf("{\\"name\\": \\"%s\\", \\"role\\": %s}", name, role);

  # COPY formato text => separar columnas con TAB
  print ext_id "\\t" json;
}' "$CSV"
\$\$
WITH (FORMAT text);
EOF
)

docker exec -i jose_db psql -U jose -d invejose -c "$SQL"

