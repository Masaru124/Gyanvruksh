#!/usr/bin/env python3
import requests
import json

# Test student login
response = requests.post('http://localhost:8000/api/auth/login',
                        json={'email': 'student@example.com', 'password': 'pass-student123'})

print(f'Status: {response.status_code}')
print(f'Response: {response.text}')
