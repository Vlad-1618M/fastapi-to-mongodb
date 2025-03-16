### License:
This project is licensed under the [MIT License](LICENSE)  
You are free to use, modify, and distribute this software under the terms of the license.

---
## **FastAPI with MongoDB as Resume Management Framework:**
`Dockerized` application setup integrating `FastAPI` server with `MongoDB` backend:<br>
This system can help individuals or organizations that require a scalable and structured way to handle large datasets.<br> 
It can be adapted for HR platforms, applicant tracking systems, research databases, or any service that demands efficient document storage and retrieval with minimal setup and maintenance effort.<br> 

The primary intent of this setup was for educational purposes, however, during development, it unexpectedly evolved into a more practical solution. <br> 
Perhaps a promising approach to a common challenge in application development and managing high-volume data efficiently when time constraints and competing priorities often push it into a never ending tech-debt.<br> 

_I wanted to address that pain point and share this as a template application that helps solve data tracking challenges,_ <br>
offering a simple yet effective solution for storing, updating, retrieving, and organizing resumes and related information seamlessly. <br>
_hope it can be usefull one day_ ...

---

## **Overview & Project Description:**
### **Dockerized application setup integrating a FastAPI server with a MongoDB backend:**
#### This repository includes:

- **`FastAPI` Server:**  
  _Modern, high-performance Python API framework._  
  _Built with asynchronous support using Python's `asyncio`, making it significantly faster than Flask or Django for I/O-bound tasks with `type hints` for `automatic validation` and `documentation generation`._  
  _Provides built-in interactive `API` docs such as `Swagger` & `Redoc` out-of-the-box._  
  _Ideal for microservices and data-driven `APIs` due to its lightweight and non-blocking architecture._  

- **`MongoDB` Server:**  
  _Robust document-based database management system._  
  _Powerful, flexible, and scalable `NoSQL` database designed for high-performance applications._  
  _Stores data in `JSON`-like `BSON` format, making it ideal for modern web applications, microservices, and real-time analytics._  

- **`Mongo-Express` App:**  
  _Lightweight, web-based `MongoDB` administration interface that allows simple `database` browsing, `CRUD` operations, and query execution with a simple UI flow._  

---

## **Containerized Services Description**

### **MongoDB Container: `resume-mongo`**
- **Purpose:** Provides a MongoDB database service for the application.
- **Environment Variables:**
  - `MONGO_INITDB_ROOT_USERNAME`: Admin user
  - `MONGO_INITDB_ROOT_PASSWORD`: Admin password
  - `MONGO_USER`: Non-admin application user
  - `MONGO_PASS`: Application user password
  - `MONGO_DB`: Default database name
- **Ports:** Exposes MongoDB on `${MONGO_PORT}:27017`
- **Persistent Storage:** Uses `mongo-data` volume to retain data across restarts
- **Health Check:** Verifies MongoDB readiness with `db.runCommand('ping').ok`

---

### **FastAPI Container: `resume-fastapi`**
- **Purpose:** Runs the FastAPI backend service.
- **Environment Variables:**
  - `MONGO_HOST`: MongoDB hostname or service name
  - `MONGO_PORT`: MongoDB service port (default `27017`)
  - `MONGO_USER`: Application user
  - `MONGO_PASS`: Application user password
  - `MONGO_DB`: Database name
- **Ports:** Exposes FastAPI on `${FASTAPI_PORT}:8000`
- **Depends On:** Starts only when MongoDB is healthy
- **Health Check:** Uses `curl` to check API availability

---

### **Mongo-Express Container: `mongo-express`**
- **Purpose:** Web-based UI for managing MongoDB data.
- **Environment Variables:**
  - `ME_CONFIG_MONGODB_ENABLE_ADMIN`: Enables admin access
  - `ME_CONFIG_MONGODB_ADMINUSERNAME`: Admin username
  - `ME_CONFIG_MONGODB_ADMINPASSWORD`: Admin password
  - `ME_CONFIG_BASICAUTH_USERNAME`: UI authentication user
  - `ME_CONFIG_BASICAUTH_PASSWORD`: UI authentication password
  - `ME_CONFIG_MONGODB_SERVER`: MongoDB service hostname
  - `ME_CONFIG_MONGODB_PORT`: MongoDB service port
  - `ME_CONFIG_OPTIONS_EDITORTHEME`: UI theme (default `dracula`)
- **Ports:** Exposes Mongo-Express on `${PORTS}:8081`
- **Depends On:** Starts after MongoDB is healthy

---

### **CI/CD Test Container: `tests-ci`**
- **Purpose:** Runs automated tests against the FastAPI service.
- **Depends On:** Starts after FastAPI is healthy
- **Command:** Runs `cicd_run.sh` script to execute test cases
- **Health Check:** Verifies API health with a `curl` request

---

### **Manual Test Container: `tests-manual`**
- **Purpose:** Provides an interactive container for running manual API tests.
- **Depends On:** Starts after FastAPI is healthy
- **Environment Variables:**
  - `BASE_URL`: FastAPI base URL
- **Command:**
  - Generates an API key if missing
  - Runs Pytest against specified test files
  - Keeps container running for additional manual tests
- **Health Check:** Uses API key to validate API availability

---

### **Docker Network & Volume**
- **Persistent Storage:** `mongo-data` volume retains MongoDB data.
- **Network:** `app-network` (bridge network for internal communication).

---
This README provides an overview of all services and existing configurations: <br>
- For detailed instructions on development, deployment, and testing:  <br> 
  - [cicd_pipeline_readme.md](/docs/cicd_pipeline_readme.md)
  - [dev_setup_readme.md](/docs/dev_setup_readme.md)
  - [endpoints_readme.md](/docs/endpoints_readme.md)
  - [pydantic_models_readme.md](/docs/pydantic_models_readme.md)
  - [mongo_cli_notes.md](/docs/mongo_cli_notes.md)
---
