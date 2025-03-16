
### ***Resume Management Framework API Endpoints Documentation:***
---
This document provides detailed reference for API's built with FastAPI and MongoDB.<br> 
It outlines each endpoint, including its `URL`, `HTTP methods`, _purpose_, _expected inputs_, _outputs_, and any special notes regarding API's behavior.<br> 
Use this file as a reference when making changes or integration testing efforts:

---

## Base URL
Base URL for the API is configured by `BASE_URL` environment variable: 
- Examples:
  - **[Local Development]:** [http://127.0.0.1:8000](http://127.0.0.1:8000)
  - **Containerized Environment:** [http://resume-fastapi:8000](http://resume-fastapi:8000)

---

## [Endpoints](/src/routes/crud_endpoints.py):

### 1. Health Check

- **Endpoint:** `GET /resume/status/health`
- **Summary:** Health check endpoint to verify the API is running.
- **Response:**
  - **200 OK**:  
    ```json
    {"status": "healthy"}
    ```
- **Docstring:**  
  *"Health check endpoint: --> returns: API status:"*

---

### 2. Create Resume

- **Endpoint:** `POST /resume/`
- **Summary:** Create a new resume.
- **Request Body:**  
  A complete `FullResume` object containing all required resume details.
- **Behavior:**
  - Converts the model to a dictionary using `model_dump()`.
  - Adds a `"created_at"` timestamp using the current UTC time.
  - Inserts the document into MongoDB.
- **Response:**
  - **200 OK**:  
    ```json
    {"message": "Resume created successfully", "id": "<resume_id>"}
    ```
- **Docstring:**  
  *"Insert a new resume data into MongoDB:
    - full_resume: --> FullResume object containing resume details:
    - returns:     --> Created resume message with ID:"*

---

### 3. Retrieve Resumes (Paginated)

- **Endpoint:** `GET /resume/`
- **Summary:** Retrieve a paginated list of resume summaries.
- **Query Parameters:**
  - `skip` (int, default: 0): Number of records to skip.
  - `limit` (int, default: 10, maximum: 100): Number of records to return.
- **Behavior:**  
  - Returns key fields from each resume (e.g., `_id`, `resume.name`, `resume.job_title.position`, etc.).
  - If no resumes exist, returns a 404 error.
- **Response:**
  - **200 OK**: List of resume summary objects.
  - **404 Not Found**: If no resumes are found.
- **Docstring:**  
  *"MongoDB pagination data retrieval:"*

---

### 4. Retrieve Resume by ID

- **Endpoint:** `GET /resume/{resume_id}`
- **Summary:** Retrieve full resume details by its unique ID.
- **Path Parameter:**  
  - `resume_id` (str): Unique identifier of the resume.
- **Behavior:**  
  - Converts the provided `resume_id` into a MongoDB `ObjectId`.
  - Returns the full resume object, converting the `_id` to a string.
  - Returns appropriate errors if the ID is invalid or not found.
- **Response:**
  - **200 OK**: Full resume details.
  - **400 Bad Request**: If `resume_id` is invalid.
  - **404 Not Found**: If no resume exists with the given ID.
- **Docstring:**  
  *"Retrieve a single resume by its ID."*

---

### 5. Update Resume (General PUT)

- **Endpoint:** `PUT /resume/`
- **Summary:** Update a single resume using a complete `FullResume` object.
- **Request Body:**  
  A complete `FullResume` object.
- **Behavior:**  
  - Uses an empty filter (`{}`) to update the first found resume in the collection.
  - (Note: This endpoint is generally for testing or single-resume scenarios.)
- **Response:**
  - **200 OK**:  
    ```json
    {"message": "Resume updated successfully:"}
    ```
  - **404 Not Found**: If no resume exists.
- **Docstring:**  
  *"Update a single resume:
    - full_resume:  --> Entire FullResume object:
    - returns:      --> Success message:
                    --> This endpoint uses update_one with an empty filter, updating the first found resume:"*

---

### 6. Bulk Update Resumes

- **Endpoint:** `PUT /resume/bulk`
- **Summary:** Update multiple resumes based on name filters.
- **Query Parameters:**
  - `first_name` (optional): Filter by first name.
  - `last_name` (optional): Filter by last name.
- **Request Body:**  
  A complete `FullResume` object.
- **Behavior:**  
  - At least one filter must be provided; otherwise, a 400 error is returned.
  - Updates all resumes matching the provided regex filter(s).
- **Response:**
  - **200 OK**:  
    ```json
    {"message": "Bulk update successful: Matched <n> and Modified <m> resumes:"}
    ```
- **Docstring:**  
  *"Bulk update resume details:
    - full_resume:  --> The FullResume object with fields to update:
    - first_name:   --> Optional filter on resume.name.first_name:
    - last_name:    --> Optional filter on resume.name.last_name:
                    --> At least one filter must be provided to avoid updating all documents:"*

---

### 7. Update Specific Resume by ID (Targeted PUT)

- **Endpoint:** `PUT /resume/{resume_id}`
- **Summary:** Update a specific resume identified by its unique ID.
- **Path Parameter:**  
  - `resume_id` (str): Unique identifier of the resume.
- **Request Body:**  
  A complete `FullResume` object.
- **Behavior:**  
  - Converts `resume_id` to an `ObjectId`.
  - Updates only the resume with the matching ID.
- **Response:**
  - **200 OK**:  
    ```json
    {"message": "Resume updated successfully:"}
    ```
  - **404 Not Found**: If no resume exists with the given ID.
- **Docstring:**  
  *"Update a specific resume:
    - resume_id:  --> Unique identifier for the resume:
    - full_resume: --> Entire FullResume object:
    - returns:     --> Success message:"*

---

### 8. Partial Update Resume by ID (PATCH)

- **Endpoint:** `PATCH /resume/{resume_id}`
- **Summary:** Partially update a resume by its ID.
- **Path Parameter:**  
  - `resume_id` (str): Unique identifier of the resume.
- **Request Body:**  
  A partial update object based on `FullResumeUpdate`.
- **Behavior:**  
  - Filters out any fields that are `None` from the provided update object.
  - Updates only those fields in the targeted resume.
- **Response:**
  - **200 OK**:  
    ```json
    {"message": "Resume with ID <resume_id> partially updated successfully."}
    ```
  - **400 Bad Request**: If `resume_id` is invalid.
  - **404 Not Found**: If no resume exists with the given ID.
- **Docstring:**  
  *"Partially update resume details by ID:
    - resume_id:    --> Unique identifier for the resume:
    - updated_data: --> Partial FullResumeUpdate object with fields to update:
    - returns:      --> Success message:"*

---

### 9. Partial Update Resume by Name (PATCH)

- **Endpoint:** `PATCH /resume/by_name/{first_name}_{last_name}`
- **Summary:** Partially update a resume based on first and last name.
- **Path Parameters:**
  - `first_name` (str): The resume’s first name.
  - `last_name` (str): The resume’s last name.
- **Request Body:**  
  A partial update object based on `FullResumeUpdate`.
- **Behavior:**  
  - Uses regex filters to match the provided first and last names.
  - Updates the first matching resume.
- **Response:**
  - **200 OK**:  
    ```json
    {"message": "Resume with ID '<resume_id>' updated successfully."}
    ```
  - **404 Not Found**: If no resume matches the provided names.
- **Docstring:**  
  *"Partially update resume details by name:
    - first_name:    --> First name of the resume to update:
    - last_name:     --> Last name of the resume to update:
    - updated_data:  --> Partial FullResumeUpdate object with fields to update:
    - returns:       --> Success message:"*

---

### 10. Delete Resume

- **Endpoint:** `DELETE /resume/{resume_id}`
- **Summary:** Delete a resume by its ID.
- **Path Parameter:**  
  - `resume_id` (str): Unique identifier of the resume.
- **Behavior:**  
  - Converts the provided `resume_id` to an `ObjectId`.
  - Deletes the matching resume document.
- **Response:**
  - **200 OK**:  
    ```json
    {"message": "Resume deleted successfully"}
    ```
  - **400 Bad Request**: If `resume_id` is invalid.
  - **404 Not Found**: If no resume exists with the given ID.
- **Docstring:**  
  *"Delete a specific resume by ID:"*

---

## Additional Notes

- **Model Conversion:**  
  Endpoints use Pydantic’s `model_dump()` method to convert models to dictionaries before inserting or updating in MongoDB.

- **Authentication:**  
  API key validation is enforced via `auth_endpoints.validate_api_key`. Clients must include the header `X-API-Key` with the correct key.

- **Logging:**  
  Each endpoint includes logging calls for monitoring actions and diagnosing issues.

- **Endpoint Variants:**  
  - **PUT (general)** updates the first found resume (using an empty filter) and is primarily for testing or single-record scenarios.
  - **PUT (targeted)** and **PATCH** endpoints update a specific resume by ID, ensuring that the correct record is modified.
  - **Bulk PUT** allows updating multiple resumes based on first and last name filters.

---

- NOTE: _This documentation is subject to `updates` as `API evolve`: <br>
  For the latest behavior and implementation details: refer to the [source](/src/) code_:

---
