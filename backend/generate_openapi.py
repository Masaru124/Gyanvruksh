#!/usr/bin/env python3
import json
import sys
import os

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from app.main import app
    openapi_spec = app.openapi()

    # Write to openapi.json
    with open('openapi.json', 'w', encoding='utf-8') as f:
        json.dump(openapi_spec, f, indent=2, ensure_ascii=False)

    print("OpenAPI specification generated successfully!")
    print(f"File saved as: {os.path.abspath('openapi.json')}")

    # Also write to YAML format for better readability
    try:
        import yaml
        with open('openapi.yaml', 'w', encoding='utf-8') as f:
            yaml.dump(openapi_spec, f, default_flow_style=False, allow_unicode=True)
        print(f"YAML version saved as: {os.path.abspath('openapi.yaml')}")
    except ImportError:
        print("PyYAML not installed, skipping YAML generation")

except Exception as e:
    print(f"Error generating OpenAPI spec: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
