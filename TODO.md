# TODO: Fix ImportError in migration_add_attendance_tables.py

## Tasks
- [x] Update import statement to use `engine` from `app.database` instead of non-existent `SQLALCHEMY_DATABASE_URL`
- [x] Remove redundant `create_engine` call since `engine` is already imported
- [ ] Test the migration script to ensure it runs without errors
