CREATE USER freshmeal WITH PASSWORD '123';

ALTER USER freshmeal NOCREATEDB freshmeal;

CREATE DATABASE freshmeal
    WITH OWNER = freshmeal
    ENCODING = 'UTF8'
    TEMPLATE template0;

GRANT ALL PRIVILEGES ON DATABASE freshmeal TO freshmeal;
