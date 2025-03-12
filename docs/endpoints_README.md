# Resume API Endpoints Documentation

This document provides a detailed reference for the Resume API built with FastAPI and MongoDB. It outlines each endpoint, including its URL, HTTP method, purpose, expected inputs, outputs, and any special notes regarding behavior. Use this file as a reference when making changes or for integration testing.

---

## Base URL

The base URL for the API is configurable via the `BASE_URL` environment variable. Examples:
- **Local Development:** `http://127.0.0.1:8000`
- **Containerized Environment:** `http://resume-fastapi:8000`

---

## Endpoints

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

*This documentation is subject to updates as the API evolves. For the latest behavior and implementation details, please refer to the source code.*



<!-- # Resume API Endpoints Documentation

This document describes the endpoints provided by the Resume API built with FastAPI and MongoDB. It serves as a reference for developers and testers when changes occur.

---

## Base URL

The base URL for the API is configurable via the `BASE_URL` environment variable. For example:
- **Local Development:** `http://127.0.0.1:8000`
- **Containerized Environment:** `http://resume-fastapi:8000`

---

## Endpoints

### 1. Health Check

- **Endpoint:** `GET /resume/status/health`
- **Description:** Returns the health status of the API.
- **Response:**
  - `200 OK` with JSON:  
    ```json
    {"status": "healthy"}
    ```

---

### 2. Create Resume

- **Endpoint:** `POST /resume/`
- **Description:** Inserts a new resume into the database.
- **Request Body:** A full resume object based on the `FullResume` Pydantic model.
- **Behavior:**  
  - Converts the resume model to a dictionary using `model_dump()`.
  - Adds a `"created_at"` timestamp.
  - Inserts the resume into MongoDB.
- **Response:**  
  - `200 OK` with JSON:  
    ```json
    {"message": "Resume created successfully", "id": "<resume_id>"}
    ```

---

### 3. Retrieve Resumes (Paginated)

- **Endpoint:** `GET /resume/`
- **Query Parameters:**
  - `skip` (int, default: 0): Number of records to skip.
  - `limit` (int, default: 10, max: 100): Number of records to return.
- **Description:** Retrieves a list of resumes with summary fields.
- **Response:**  
  - `200 OK` with a list of resume summaries.
  - If no resumes are found, returns `404 Not Found` with detail `"No resume found:"`

---

### 4. Retrieve Resume by ID

- **Endpoint:** `GET /resume/{resume_id}`
- **Description:** Retrieves the complete details of a resume using its unique ID.
- **Path Parameter:**  
  - `resume_id` (str): The unique identifier for the resume.
- **Behavior:**  
  - Converts the provided `resume_id` to a MongoDB `ObjectId`.
  - Returns the resume data (with `_id` converted to string).
- **Response:**  
  - `200 OK` with resume details.
  - `400 Bad Request` if `resume_id` is invalid.
  - `404 Not Found` if the resume does not exist.

---

### 5. Update Resume (General PUT)

- **Endpoint:** `PUT /resume/`
- **Description:** Updates a single resume using a full resume object.
- **Request Body:** A full resume object based on `FullResume`.
- **Behavior:**  
  - Uses an empty filter (`{}`) to update the first found resume.
  - **Note:** This endpoint is typically for testing or scenarios where only one resume exists.
- **Response:**  
  - `200 OK` with JSON:  
    ```json
    {"message": "Resume updated successfully:"}
    ```
  - `404 Not Found` if no resumes exist.

---

### 6. Bulk Update Resumes

- **Endpoint:** `PUT /resume/bulk`
- **Description:** Updates multiple resumes based on name filters.
- **Query Parameters:**
  - `first_name` (optional): Filter by first name.
  - `last_name` (optional): Filter by last name.
- **Request Body:** A full resume object based on `FullResume`.
- **Behavior:**  
  - Requires at least one filter parameter.
  - Updates all resumes matching the provided filters.
- **Response:**  
  - `200 OK` with JSON detailing the number of matched and modified resumes.
  - `400 Bad Request` if no filter is provided.

---

### 7. Update Specific Resume (PUT by ID)

- **Endpoint:** `PUT /resume/{resume_id}`
- **Description:** Updates a specific resume identified by its ID.
- **Path Parameter:**  
  - `resume_id` (str): The resume's unique identifier.
- **Request Body:** A full resume object based on `FullResume`.
- **Behavior:**  
  - Converts `resume_id` to a MongoDB `ObjectId`.
  - Updates only the matching resume.
- **Response:**  
  - `200 OK` with JSON:  
    ```json
    {"message": "Resume updated successfully:"}
    ```
  - `404 Not Found` if the resume does not exist.

---

### 8. Partial Update Resume by ID (PATCH)

- **Endpoint:** `PATCH /resume/{resume_id}`
- **Description:** Partially updates a resume by its ID.
- **Path Parameter:**  
  - `resume_id` (str): The unique identifier for the resume.
- **Request Body:** A partial update object based on `FullResumeUpdate`.
- **Behavior:**  
  - Filters out `None` values and updates only the provided fields.
- **Response:**  
  - `200 OK` with JSON:  
    ```json
    {"message": "Resume with ID <resume_id> partially updated successfully."}
    ```
  - `400 Bad Request` if `resume_id` is invalid.
  - `404 Not Found` if the resume does not exist.

---

### 9. Partial Update Resume by Name (PATCH)

- **Endpoint:** `PATCH /resume/by_name/{first_name}_{last_name}`
- **Description:** Partially updates a resume using first and last name.
- **Path Parameters:**
  - `first_name` (str): The resume's first name.
  - `last_name` (str): The resume's last name.
- **Request Body:** A partial update object based on `FullResumeUpdate`.
- **Behavior:**  
  - Searches using regex matching.
  - Updates the first matching resume.
- **Response:**  
  - `200 OK` with JSON:  
    ```json
    {"message": "Resume with ID '<resume_id>' updated successfully."}
    ```
  - `404 Not Found` if no matching resume is found.

---

### 10. Delete Resume

- **Endpoint:** `DELETE /resume/{resume_id}`
- **Description:** Deletes a resume by its ID.
- **Path Parameter:**  
  - `resume_id` (str): The unique identifier for the resume.
- **Behavior:**  
  - Converts `resume_id` to a MongoDB `ObjectId` and deletes the document.
- **Response:**  
  - `200 OK` with JSON:  
    ```json
    {"message": "Resume deleted successfully"}
    ```
  - `400 Bad Request` if `resume_id` is invalid.
  - `404 Not Found` if the resume does not exist.

---

## Additional Notes

- **Model Conversion:**  
  Endpoints use Pydantic’s `model_dump()` (or previously `dict()`) to convert models into dictionaries.

- **Authentication:**  
  API key validation is handled by the dependency `auth_endpoints.validate_api_key`. Ensure that the key is provided in the header (`X-API-Key`).

- **Logging:**  
  Logging is performed throughout the endpoints for debugging and monitoring.

- **Bulk and Partial Updates:**  
  The PUT endpoint with an empty filter is for updating the first found resume. The bulk endpoint updates multiple documents based on name filters. PATCH endpoints provide partial updates, with one using the resume ID and one using the name.

- **Usage:**  
  Use the targeted PUT (`PUT /resume/{resume_id}`) or PATCH (`PATCH /resume/{resume_id}`) endpoints to update a specific resume when needed. Bulk updates are useful for mass changes based on filters.

---

*This documentation is subject to change. Please refer to the source code for the most accurate and up-to-date information on API behavior.* -->
