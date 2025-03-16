# **CI/CD: GitHub Actions and Docker Compose:**

## **Pipeline Build Process Overview:**
The pipeline is designed to _build_, _test_, _deploy_, and _teardown_ the `Resume Management Framework` created with `FastAPI` and `MongoDB` server apps while considering exisitng compatibility limitations caused by _GitHub's free-tier_ runners: <br>
This document explains how the _CI/CD_ pipeline is structured using [GitHub Actions](/.github/workflows/cicd-build.yml) and the differences between the [dev/test](/build/docker-compose.yml) vs [github_pipeline](/build/docker-compose-github.yml) setup: 

---

## **Why Two Docker Compose Files ?**
### `1` [docker-compose.yml](/build/docker-compose.yml) → **Full Local Setup**:
- Designed for **development and testing**:
- Includes **all five containers**: <br>
    - `resume-mongo` 
    - `resume-fastapi` 
    - `mongo-express`
    - `tests-ci`
    - `tests-manual`
- No memory issues, uses **default MongoDB settings**: 
- Provides **default Mongo-Express** web-app:
- Provides **default FastAPI-Swagger** web-app:
- Provides **default FastAPI-Redoc** web-app as an alternative:
- Provides an entire container orchestration setup, deployed and auto-launched in the default terminal _macOS only_, with a logged-in Docker session for each app component:
- Equipped with automation tool scripts to ease the learning curve around development and testing needs. See [dev_setup](/docs/dev_setup_readme.md) for more info:



### `2` [docker-compose-github.yml](/build/docker-compose-github.yml) → **CI/CD Optimized**:
- Created **specifically for _GitHub_ Actions**, due to discovered **memory limitations** on free-tier runners:
- **Key Modifications:**
  - **Removed `mongo-express` and `tests-manual`** containers to reduce memory load:
  - **Reduced MongoDB memory allocation (`shm_size: "256m"`)** to prevent _SIGKILL_ exit code `137` _OOM_ errors:
  - **Defined `deploy.resources.limits.memory: 512M`** to explicitly cap resource usage:
  - **Ensured health checks run efficiently** to avoid unnecessary container restarts:

---

## **GitHub Actions Workflow: `cicd-build.yml`**
The CI/CD pipeline is defined in [ .github/workflows/cicd-build.yml ](/.github/workflows/cicd-build.yml) and has the following job sequence:


>Trigger Conditions:
>- Runs **on push and pull requests** to the `v.tools_main` branch or any other branch (`'**'`)

>Execution Flow:
>- Checkout Repository:
>   - `actions/checkout@v4` to pull the latest repository state:
>- Set Up Docker Environment:
>   - Configures `QEMU` and `Buildx` for multi-platform support:
>   - Defines `DOCKER_DEFAULT_PLATFORM=linux/amd64`:
>- Start CI/CD Docker Containers:
>   - Runs `docker compose -f build/docker-compose-github.yml up --build -d`:
>- Wait for Containers to be Ready:
>   - Ensures all services are healthy before proceeding:
>- Show Running Containers process _similar to `--progress=plain` flag_ in docker builds:
>   - Executes `docker compose -f build/docker-compose-github.yml ps`:

> Run Integration Tests:
> - Executes tests within `tests-ci` container: <br>
> - `ping -c 4 -w 5 resume-fastapi` → sends `4 ICMP` ping requests to `resume-fastapi` container to verify network connectivity:
> - `curl -v http://resume-fastapi:8000/` → Makes an `HTTP request` to `FastAPI` service to ensure it is running and is responding:
> - calls [cicd_run.sh](/build/sh_scripts/cicd_run.sh) orchestration shell script which runs automated integration [tests](/tests/py_tests/) and validates [endpoints](/src/routes/crud_endpoints.py) `API` behavior:

```bash
docker compose -f build/docker-compose-github.yml exec tests-ci sh -c "
ping -c 4 -w 5 resume-fastapi &&
curl -v http://resume-fastapi:8000/ &&
./build/sh_scripts/cicd_run.sh"
```

>Shut Down Containers:
>- Clean up by stopping all containers using `docker compose down` call:

---

### **CI/CD [Shell Orchestration](/build/sh_scripts/cicd_run.sh) Script:**
The script controls:
- `setup` 
- `test execution` flow
- `cleanup` within the `GitHub Actions` runner:

#### **Key Features:**
- **Verifies FastAPI availability** using `ping` and `curl` calls:
- [Generates API keys](/tests/curl_tests/get_auth_key.sh) authentication token prior to test init: 
- Executes [Pytest](/tests/py_tests/) test flow:
  - **Mock Tests [test_mock_endpoints.py](/tests/py_tests/test_mock_endpoints.py)** → runs `fastapi.testclient` with `mongomock` to enable mock testing without requiring a real application setup: <br>
  Overrides actual dependencies, allowing unit tests to run with predefined _FastAPI_ [models](/src/models/base_models.py): <br>
  Provides a quick isolated unit tests by removing external dependencies while testing API request/response flows: <br>
  Useful for testing during developmnet of an endpoint logic validation with no need on infrastructure or real database response:
  - **True API Tests [test_true_endpoints_sets.py](/tests/py_tests/test_true_endpoints_sets.py)** → Uses real test data: <br>
  Executes a full suite of API tests using real test data: <br>
  This includes _authentication_, CRUD operations for resumes: <br>
  _API_ key validation and database integrity checks: <br>
  Tests designed to check endpoints correctly handle expected and edge-case scenarios, with dependency-based execution and assertions for API responses:
  - **CRUD Cycle Tests [test_crud_cycle_true_endpoints.py](/tests/py_tests/test_crud_cycle_true_endpoints.py)** → Grouped test cases per dataset: <br>
  Executes a structured set of tests for each dataset, covering the full _lifecycle_ of a resume entry: <br>
  Tests include _health_ checks, data _creation_ and _retrieval_, _full_ and _partial_ updates as well as _deletion_ / cleaup:<br> Tests designed to validate database integrity is maintained and verifies _MongoDB_ authentication cleanup by _revoking_ API keys and _removing_ test data post-execution:

---

## **Final Notes:**
- The CI/CD pipeline ensures **automated builds, testing, and resource-efficient execution**.
- The GitHub-specific `docker-compose-github.yml` optimizes memory usage to **avoid SIGKILL (OOM errors)**.
- `cicd_run.sh` manages **setup, API key generation, test execution, and cleanup**.

For further details: <br>
... refer to the respective scripts linked in this document flow:

---

