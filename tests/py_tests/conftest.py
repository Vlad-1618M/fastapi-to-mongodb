#!/usr/bin/env python
"""
==================================================================================================
Mocked PyTests: conftest.py
- This file sets up fixtures for pytest, including overriding the real MongoDB connection with an
  in-memory mongomock instance. This way, your tests run in a stable, controlled environment.
- It also instantiates the FastAPI TestClient and provides common fixtures (e.g. a sample payload,
  created_resume) for use in your endpoint tests.
  
Author    : 
Date      : 2025-03-04
Version   : 1.0
Contact   : @gmail.com
==================================================================================================
"""

import os
import sys
import json
import pytest
import mongomock
from time import sleep
from pathlib import Path
from functools import wraps
from fastapi.testclient import TestClient

# ... application modules import:
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from src.server import app
from db import db as real_db

# BASE_URL = os.getenv("BASE_URL", "http://resume-fastapi:8000")
# @pytest.fixture(scope="session")
# def base_url():
#     return BASE_URL


# ... override existing collection to use mongomock:
@pytest.fixture(autouse=True)
def override_resume_collection(monkeypatch):
    mock_client = mongomock.MongoClient()
    mock_db = mock_client['test_db']
    fake_resume_collection = mock_db['resumes']
    # ... replace function/attribute which return resumes data collection:
    monkeypatch.setattr(real_db, "db_collections", lambda: fake_resume_collection)

# ... override API keys collection to use mongomock:
@pytest.fixture(autouse=True)
def override_api_keys_collection(monkeypatch):
    mock_client = mongomock.MongoClient()
    mock_db = mock_client['test_db']
    fake_api_keys_collection = mock_db['api_keys']
    
    # ... insert test API key | matching the one used in tests:
    fake_api_keys_collection.insert_one({"key": "testkey"})
    monkeypatch.setattr(real_db, "get_api_keys_collection", lambda: fake_api_keys_collection)

client = TestClient(app)

# ... fixed API key and headers for testing:
API_KEY = "testkey"
HEADERS = {"X-API-Key": API_KEY}

# ... a resume payload example for mock tests:
@pytest.fixture(scope="session")
def mock_payload():
    return {
        "resume": {
            "name": {"first_name": "Mock", "last_name": "Test"},
            "location": {
                "address": {
                    "country": "USA",
                    "state": "CA",
                    "city": "San Francisco",
                    "zip_code": "94105",
                    "timezone": "PST"
                }
            },
            "contact": {"email": "mock.test.user@example.com", "phone": "+1-415-123-4567"},
            "job_title": {"position": "Developer", "role": "Software Engineer"},
            "summary": "Test resume summary.",
            "skills": {"Python": {"Expert": True}},
            "Programming_Languages": {},
            "Automation": {},
            "Testing": {},
            "Development_Tools": {},
            "Web_Technologies": {},
            "Build_Tools": {},
            "DevOps": {},
            "Microservices": {},
            "Databases": {},
            "Version_Control": {},
            "OS_Architecture": {},
            "Virtualization_Compute": {},
            "Network_Protocols": {},
            "Management_Tools": {}
        },
        "Work_Experience": [
            {
                "org_name": "Test Org",
                "location": "Test City",
                "employment_length": "2020-2021",
                "role": "Engineer",
                "job_description": "Did engineering work."
            }
        ],
        "education": {
            "degree": "BSc",
            "location": "Test University",
            "majored_in": "Computer Science"
        },
        "work_authorization": "US Citizen",
        "reference": {},
        "links": {},
        "notes": "Test notes."
    }

# ... fixture | create resume | clean up after:
@pytest.fixture
def created_resume(mock_payload):
    response = client.post("/resume/", json=mock_payload, headers=HEADERS)
    assert response.status_code == 200, f"Create failed: {response.text}"
    data = response.json()
    resume_id = data.get("id")
    yield resume_id
    client.delete(f"/resume/{resume_id}", headers=HEADERS)

# ... expose client, API key and payload as fixtures:
@pytest.fixture
def test_client():
    return client

@pytest.fixture(scope="session")
def api_mock_headers():
    return {"X-API-Key": "testkey"}

# ... dummy_payload --> returns the actual payload dictionary:
@pytest.fixture(scope="session")
def dummy_payload(mock_payload):
    return mock_payload

@pytest.fixture(scope="session")
def get_mocked_json():
    json_file= Path('/dbapp/tests/data_sets/resumes/Abraham_Lincoln.json')
    with json_file.open("r", encoding="utf-8") as mock_json:
        return json.load(mock_json)

@pytest.fixture
def tag_id(request):
    tag = getattr(request, "param", {})
    tag.setdefault("test_name", request.node.name)
    return tag

@pytest.fixture(scope="session")
def api_true_headers():
    key_file = Path("/tmp/api_key.txt")
    if key_file.exists():
        with key_file.open("r", encoding="utf-8") as f:
            api_key = f.read().strip()
    else:
        # Optionally, trigger a request to obtain a new key here.
        api_key = "testkey"
    return {"X-API-Key": api_key}


@pytest.fixture(autouse=True)
def debug_delay_between_tests():
    yield
    sleep(0.07)
    # sleep(1)

# @pytest.fixture(autouse=True)
def run_benchmark(test_name):
    def decorator(func):
        @wraps(func)
        @pytest.mark.benchmark(group=test_name)
        def wrapper(*args, **kwargs):
            return func(*args, **kwargs)
        return wrapper
    return decorator


if __name__ == "__main__":
    pass
    # [print(_) for _ in get_mocked_json().items()]
    # [print(f'count:\t --> {_indx}, file name:\t --> {name}', end="\n\n") for _indx, name in enumerate(load_all_resume_data(), start=1)]
