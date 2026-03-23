FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

COPY ./restore.sh /usr/local/bin/restore.sh

RUN chmod +x /usr/local/bin/restore.sh

ENTRYPOINT ["/usr/local/bin/restore.sh"]