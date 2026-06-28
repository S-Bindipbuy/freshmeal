CREATE USER freshmeal_user WITH PASSWORD '123';

ALTER USER freshmeal NOCREATEDB;

CREATE DATABASE freshmeal
    WITH OWNER = freshmeal
    ENCODING = 'UTF8'
    TEMPLATE template0;

GRANT ALL PRIVILEGES ON DATABASE freshmeal TO freshmeal_user;
