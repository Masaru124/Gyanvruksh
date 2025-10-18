#!/usr/bin/env python3
import requests
import json

# Test student login with detailed error checking
response = requests.post('http://localhost:8000/api/auth/login',
                        json={'email': 'student@example.com', 'password': 'pass-student123'})

print(f'Status: {response.status_code}')
print(f'Response: {response.text}')

# Also test with a simple health check
try:
    health = requests.get('http://localhost:8000/healthz')
    print(f'Health check: {health.status_code}')
except Exception as e:
    print(f'Health check error: {e}')
