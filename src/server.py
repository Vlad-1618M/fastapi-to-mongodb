#!/usr/bin/env python

from fastapi import FastAPI
from routes.crud_endpoints import router as resume_router
from auth.auth_endpoints import router as auth_router

app = FastAPI()
app.include_router(auth_router)
app.include_router(resume_router)

@app.get("/", summary="API Root", response_description="Welcome message")
async def root():
    return {"message": "Welcome to the Resume API!"}


if __name__ == "__main__":
    pass
