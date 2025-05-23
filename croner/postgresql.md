
# PostgreSQL
```sh
# 备份
pg_dump -U example -d example -f /test.sql
# 恢复
psql -U example -c "CREATE DATABASE example2;"
psql -U example -d example2 < /test.sql
```
