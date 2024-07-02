FROM mcr.microsoft.com/mssql/server:2022-latest

# Install libicu package
USER root
RUN apt-get update && apt-get install -y libicu72


ENV SA_PASSWORD=P@ssw0rd
ENV ACCEPT_EULA=Y

# Copy init.sql to the SQL Server initialization directory
COPY init-db.sql /workspace/db/init-db.sql

# The default command will start the SQL Server
CMD [ "sqlservr" ]
