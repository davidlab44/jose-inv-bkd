#!/bin/bash

# create-table.sh
# Uso: ./create-table.sh nombre_tabla

# Verificar que se pase un parámetro
if [ $# -ne 1 ]; then
  echo "Uso: $0 <nombre_tabla>"
  exit 1
fi

TABLA="$1"
SECUENCIA="${TABLA}_id_seq"

# Comandos SQL a ejecutar
SQL=$(cat <<EOF
-- Crear tabla con JSONB
CREATE TABLE IF NOT EXISTS $TABLA (
    id SERIAL PRIMARY KEY,
    creado_en TIMESTAMPTZ DEFAULT now(),
    datos JSONB NOT NULL
);

-- Configurar permisos
GRANT USAGE, SELECT ON SEQUENCE $SECUENCIA TO web_anon;
GRANT UPDATE ON SEQUENCE $SECUENCIA TO web_anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.$TABLA TO web_anon;
EOF
)

# Ejecutar comandos SQL dentro del contenedor Docker
docker exec -i jose_db psql -U jose -d invejose -c "$SQL"

