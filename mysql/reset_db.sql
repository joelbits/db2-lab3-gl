DROP DATABASE IF EXISTS `MYSQL_DATABASE` ;
CREATE DATABASE IF NOT EXISTS `MYSQL_DATABASE`;
USE `MYSQL_DATABASE`;

SOURCE /etc/mysql/users.sql;
SOURCE /etc/mysql/orders.sql;