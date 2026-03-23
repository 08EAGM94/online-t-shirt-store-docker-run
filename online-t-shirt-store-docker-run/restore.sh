#!/bin/bash
/opt/mssql/bin/sqlservr &

echo "Esperando a que SQL Server esté disponible..."
for i in {1..50};
do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SQL Server listo después de $i segundos."
        break
    fi
    sleep 1s
done

if [ $? -ne 0 ]; then
    echo "ERROR: SQL Server no inició tras 50 segundos. Abortando..."
    exit 1  
fi

echo "Verificando si la base de datos 'TiendaMaster' ya existe..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q \
"IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TiendaMaster')
BEGIN
    PRINT 'TiendaMaster no encontrada. Iniciando restauración desde backup...'
    RESTORE DATABASE TiendaMaster 
    FROM DISK = '/var/opt/mssql/backup/TiendaMaster.bak' 
    WITH MOVE 'TiendaMaster' TO '/var/opt/mssql/data/TiendaMaster.mdf', 
         MOVE 'TiendaMaster_log' TO '/var/opt/mssql/data/TiendaMaster.ldf'
END
ELSE
BEGIN
    PRINT 'TiendaMaster ya existe en el volumen persistente. Saltando restauración.'
END"

wait