from app.services.security import hash_password, verify_password

# Test password hashing and verification
password = "masarukaze041@gmail.com"
hashed = hash_password(password)
print(f"Original password: {password}")
print(f"Hashed password: {hashed}")
print(f"Verification result: {verify_password(password, hashed)}")

# Test with wrong password
wrong_password = "wrongpassword"
print(f"Wrong password verification: {verify_password(wrong_password, hashed)}")
