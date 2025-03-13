#!/usr/bin/env python

import sys
import db as mongo_setup
from pathlib import Path
import api_key_generator

sys.path.append(str(Path(__file__).resolve().parent.parent))
from logger import logger_main

logger = logger_main.get_logger(__name__)

def init_api_keys():
    """Initialize API keys collection if not already present: """
    api_keys_collection = mongo_setup.get_api_keys_collection()
    if not api_keys_collection.find_one({"key": {"$exists": True}}):  # <-- valid API key exists check:
        generated_key = api_key_generator.generate_api_key()
        api_keys_collection.insert_one({"key": generated_key})
        print(f"\nGenerated and stored API Key: {generated_key}\n")
    else:
        print("\nAPI Key already exists.\n")

def resume_db_connect():
    """Connects to MongoDB and initializes the database structure: """
    db_client = mongo_setup.get_db_client()
    if "resume" not in db_client.list_collection_names():
        db_client["resume"].insert_one({"init": "placeholder"})        # <-- # safe db creation:

    resume_collection = mongo_setup.db_collections()                   # <-- Init db_collection_schema.yml data if empty:
    if resume_collection.count_documents({}) == 0:
        resume_collection.insert_one(mongo_setup.load_config())
        print("\nMongoDB init successful:\n\tCollections source --> db_collection_schema.yml")
    else:
        print("\nMongoDB already initialized.\n")

if __name__ == "__main__":
    pass
    # Uncomment for manual execution:
    # init_api_keys()
    # resume_db_connect()
