#!/usr/bin/env python3
from app.database import SessionLocal
from app.models.user import User

db = SessionLocal()
try:
    student = db.query(User).filter(User.email == 'student@example.com').first()
    if student:
        print(f'Student found:')
        print(f'  Email: {student.email}')
        print(f'  Role: {student.role}')
        print(f'  Sub-role: {student.sub_role}')
        print(f'  Is active: {student.is_active}')
        print(f'  Password hash: {student.hashed_password[:20]}...')
    else:
        print('Student user not found in database')

    # Check all users
    all_users = db.query(User).all()
    print(f'\nTotal users in database: {len(all_users)}')
    for user in all_users:
        print(f'  - {user.email} ({user.role}/{user.sub_role})')

except Exception as e:
    print(f'Error: {e}')
finally:
    db.close()
