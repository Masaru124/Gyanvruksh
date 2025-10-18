#!/usr/bin/env python3
from app.database import SessionLocal
from app.models.user import User
from app.services.security import hash_password, verify_password

db = SessionLocal()
try:
    student = db.query(User).filter(User.email == 'student@example.com').first()
    if student:
        print(f'Student found: {student.email}')
        print(f'Role: {student.role}')
        print(f'Sub-role: {student.sub_role}')
        print(f'Is active: {student.is_active}')

        # Test password
        test_password = 'pass-student123'
        is_valid = verify_password(test_password, student.hashed_password)
        print(f'Password verification for "{test_password}": {is_valid}')

        if not is_valid:
            print('Resetting password...')
            student.hashed_password = hash_password(test_password)
            db.commit()
            print('Password reset complete')

            # Test again
            is_valid = verify_password(test_password, student.hashed_password)
            print(f'Password verification after reset: {is_valid}')
    else:
        print('Student user not found in database')
except Exception as e:
    print(f'Error: {e}')
finally:
    db.close()
