from app.services.security import hash_password, verify_password

# Test password hashing and verification
password = "masarukaze041@gmail.com"
hashed = hash_password(password)
verification_result = verify_password(password, hashed)

# Test with wrong password
wrong_password = "wrongpassword"
wrong_verification_result = verify_password(wrong_password, hashed)
