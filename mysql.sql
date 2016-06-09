drop user 'root'@'127.0.0.1';
drop user 'root'@'::1';
delete from mysql.user where user = 'root' and host = @@hostname;
delete from mysql.user where user = '';
grant ALL on *.* to 'root'@'192.168.56.10' identified by 'root123';
