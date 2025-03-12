#!/usr/bin/env python

import os
import sys
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import APIKeyHeader

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
from db import api_key_generator, db as access_mongo
from logger import logger_main

router = APIRouter(prefix="/auth", tags=["auth"])
logger = logger_main.get_logger(__name__)

api_key_header = APIKeyHeader(name="X-API-Key")                                                     # <-- API key authentication header:

def validate_api_key(api_key: str = Depends(api_key_header)):                                       # <-- alidate Key:
    """Validate API key from MongoDB."""
    api_keys_collection = access_mongo.get_api_keys_collection()
    
    # shoudl usefind_one() instead of count_documents() for efficiency or so web docs say ... 
    if not api_keys_collection.find_one({"key": api_key}):
        logger.warning("Unauthorized API key attempt")
        raise HTTPException(status_code=403, detail="Invalid API key.")                             # <-- Use 403 Forbidden:
    
    return True

@router.post("/generate-api-key", summary="Generate a new API key", response_description="API Key")  # <-- API Key gen: 
async def generate_new_api_key():
    """Generate and store a new API key."""
    new_key = api_key_generator.generate_api_key()
    api_keys_collection = access_mongo.get_api_keys_collection()
    api_keys_collection.insert_one({"key": new_key})
    
    logger.info("New API token generated")
    return {"message": "New API key generated", "api_key": new_key}

@router.get("/api-keys", summary="Retrieve existing API keys", response_description="List of API Keys")  # <-- retrieve Keys:
async def get_existing_api_keys(api_key: bool = Depends(validate_api_key)):
    """Retrieve stored API keys."""
    api_keys_collection = access_mongo.get_api_keys_collection()
    keys = [key["key"] for key in api_keys_collection.find({}, {"_id": 0})]

    if not keys:
        raise HTTPException(status_code=404, detail="No API keys found.")

    return {"api_keys": keys}

@router.delete("/revoke-api-key", summary="Revoke an API key", response_description="Success message")  # <-- revoke API Key:
async def revoke_api_key(api_key_to_revoke: str, api_key: bool = Depends(validate_api_key)):
    """Revoke (delete) a specific API key."""
    api_keys_collection = access_mongo.get_api_keys_collection()
    result = api_keys_collection.delete_one({"key": api_key_to_revoke})

    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="API key not found.")

    logger.info(f"API key revoked: {api_key_to_revoke}")
    return {"message": "API key revoked successfully"}


if __name__ == "__main__":
    pass



# something to thing abou: ______________________________________________________________________________
# Might be good ide to extend Auth Endpoints by additing two new endpoints to auth module that implement:
#   Count API Keys:      --> endpoint which returns the count of all existing API key tokens in DB:
#   Remove All API Keys: --> endpoint that removes all API key tokens at once:

#  __________ code thoughts: _________________________________________________________________________ 
# @router.get("/count_api_keys", summary="Count API keys", response_description="Number of API keys")
# async def count_api_keys(api_key: bool = Depends(validate_api_key)):
#     api_keys_collection = access_mongo.get_api_keys_collection()
#     count = api_keys_collection.count_documents({})
#     return {"count": count}

# @router.post("/remove_api_keys", summary="Remove all API keys", response_description="Success message")
# async def remove_api_keys(api_key: bool = Depends(validate_api_key)):
#     api_keys_collection = access_mongo.get_api_keys_collection()
#     result = api_keys_collection.delete_many({})
#     return {"message": "API keys removed successfully", "deleted_count": result.deleted_count}
# _______________________________________________________________________________________________________ 