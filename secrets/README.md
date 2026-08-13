# Local Secrets

Create these files locally before running the stack:

- `db_password.txt`
- `db_root_password.txt`

Example:

```sh
echo "strong_db_password" > secrets/db_password.txt
echo "strong_root_password" > secrets/db_root_password.txt
chmod 600 secrets/db_password.txt secrets/db_root_password.txt
```

Do not commit real secret values.
