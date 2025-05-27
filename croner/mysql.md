# Mysql
```shell
# 备份
mysqldump -u root -p --all-databases > all_databases.sql
# 恢复
mysqldump -u root -p --all-databases < all_databases.sql
```