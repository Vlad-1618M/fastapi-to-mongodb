#!/usr/bin/env python

import os
import sys
import yaml
from pathlib import Path
from pymongo import MongoClient

sys.path.append(str(Path(__file__).resolve().parent))
import globals

sys.path.append(str(Path(__file__).resolve().parent.parent))
from logger import logger_main
logger = logger_main.get_logger(__name__)

def load_config():
        """ .yml load """
        mongodb_schema = list(Path(__file__).resolve().parent.parent.glob('cfgs/*_schema.yml'))
        if not mongodb_schema:
            logger.warning(f".yml mongodb_schema config not found: {[_.name for _ in Path('cfgs').iterdir()]}")
            raise FileNotFoundError("\t.yml mongodb_schema config not found:")
        
        with open(mongodb_schema[0], 'r') as dbconfig:
            return yaml.safe_load(dbconfig)

def get_db_client():
    """Returns MongoDB database client"""
    client = MongoClient(globals.MONGO_URI)
    return client[globals.MONGO_DB]

def db_collections():
    """Returns the 'resume' collection"""
    return get_db_client()["resume"]

def get_api_keys_collection():
    """Returns the 'api_keys' collection"""
    return get_db_client()["api_keys"]

def debug_envs():
     resume_schema = load_config()
     [print(f"\nLoaded Collection Structure: -->\t{key}: {value}") for key, value in resume_schema.items()]
     print("="*70, end="\n\n")
     
     [print(f"Resume Collection Preview: -->\t{key}: {value}") for key, value in resume_schema.get("resume", {}).items()]
     print("="*70, end="\n\n")
     
     work_exp = resume_schema.get("resume", {}).get("Work_Experience", [])
     for indx, details in enumerate(work_exp, start=0):
        print(f"Work Experience Entry: -> {indx + 1} | {details}")
     print("="*70, end="\n\n")
     
     print("\n".join(map(lambda k: f"Mongo_DB {k[0]}: {os.getenv(k[1])}",[
          ("HOST", "MONGO_HOST"), ("PORT", "MONGO_PORT"), 
          ("User", "MONGO_USER"), ("Password", "MONGO_PASS"), 
          ("Database", "MONGO_DB"), ("URI", "MONGO_UR")])))
     
     print("\n---Done: ---\n")

if __name__ == "__main__":
     pass
