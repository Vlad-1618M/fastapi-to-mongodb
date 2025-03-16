# Resume Management Model:

Repository implements a resume management system using [Pydantic](https://docs.pydantic.dev/latest/). <br>
The models are designed for the creation, validation, and updating of resume data—making them ideal for resume parsing, API endpoints, database integrations, and dynamic data updates:

## Overview

The data models are organized in a modular way. They start with core building blocks for capturing basic personal and contact information and extend to comprehensive structures for full resume details. This approach helps in validation and scalability for applications using frameworks like FastAPI and MongoDB:

## Directory Structure:

```
── __init__.py
├── auth
│   └── auth_endpoints.py
├── helpers
│   └── timer.py
├── models
│   └── base_models.py
├── routes
│   └── crud_endpoints.py
└── server.py

```
### Building Blocks:
The foundation of the resume [data model](/src/models/base_models.py) includes:

- **Name Model:** Captures first and last names.
- **Address Model:** Defines location details (country, state, city, zip code, timezone).
- **Contact Model:** Stores contact information like email and phone.
- **JobTitle Model:** Specifies job position and role.
- **LocationWrapper Model:** Organizes address information into a unified format.
```python
from pydantic import BaseModel, Field

class Name(BaseModel):
    first_name: str
    last_name: str

class Address(BaseModel):
    country: str = ""
    state: str = ""
    city: str = ""
    zip_code: str = ""
    timezone: str = ""

class Contact(BaseModel):
    email: str = ""
    phone: str = ""

class JobTitle(BaseModel):
    position: str = ""
    role: str = ""

class LocationWrapper(BaseModel):
    address: Address = Field(default_factory=Address)
```

### Main Resume Models:
- **BasicResumeData**: model collects essential resume details needed for initial resume creation _(e.g POST request):_
- `name`: Name object.
- `location`: LocationWrapper object.
- `contact`: Contact object.
- `job_title`: JobTitle object.

```python
class BasicResumeData(BaseModel):
    name: Name
    location: LocationWrapper = Field(default_factory=LocationWrapper)
    contact: Contact = Field(default_factory=Contact)
    job_title: JobTitle = Field(default_factory=JobTitle)

```
**Extended Resume Data:** model extends **BasicResumeData** with additional fields:
- `summary`: _brief overview_
- `skills`: _dictionary for categorizing skills_ <br>
**Specific categories** such as:
    - `Programming Languages`
    - `Automation`
    - `Testing`
    - `Development Tools`
    - `Web Technologies`
    - `Build Tools`
    - `DevOps`
    - `Microservices`
    - `Databases`
    - `Version Control`
    - `OS Architecture`
    - `Virtualization & Compute`
    - `Network Protocols`
    - `Management Tools`

```python
from typing import Optional, Dict, Any

class ExtendedResumeData(BasicResumeData):
    summary: Optional[str] = None
    skills: Dict[str, Dict] = Field(default_factory=dict)
    Programming_Languages: Dict[str, Any] = Field(default_factory=dict)
    Automation: Dict[str, Any] = Field(default_factory=dict)
    Testing: Dict[str, Any] = Field(default_factory=dict)
    Development_Tools: Dict[str, Any] = Field(default_factory=dict)
    Web_Technologies: Dict[str, Any] = Field(default_factory=dict)
    Build_Tools: Dict[str, Any] = Field(default_factory=dict)
    DevOps: Dict[str, Any] = Field(default_factory=dict)
    Microservices: Dict[str, Any] = Field(default_factory=dict)
    Databases: Dict[str, Any] = Field(default_factory=dict)
    Version_Control: Dict[str, Any] = Field(default_factory=dict)
    OS_Architecture: Dict[str, Any] = Field(default_factory=dict)
    Virtualization_Compute: Dict[str, Any] = Field(default_factory=dict)
    Network_Protocols: Dict[str, Any] = Field(default_factory=dict)
    Management_Tools: Dict[str, Dict] = Field(default_factory=dict)

```
**Full Resume Model:** combines extended resume details with additional sections represents a complete resume:
- `resume`: An ExtendedResumeData object:
- `Work_Experience`: list of work experience entries:
- `education`: Education records:
- `work_authorization`: Optional work authorization information:
- `reference`: Dictionary for references:
- `links`: Dictionary for URLs _(e.g., LinkedIn, GitHub)_
- `notes`: Extra notes or remarks:

```python
from typing import List, Optional

class FullResume(BaseModel):
    resume: ExtendedResumeData
    Work_Experience: List[WorkExperience] = Field(default_factory=list)
    education: Education = Field(default_factory=Education)
    work_authorization: Optional[str] = None
    reference: Dict[str, str] = Field(default_factory=dict)
    links: Dict[str, Dict] = Field(default_factory=dict)
    notes: Optional[str] = None

```
**Partial Resume Update:** `PATCH` requests: `_FullResumeUpdate_` model allows updating only a subset of fields: _all_ properties are optional:
```python
class FullResumeUpdate(BaseModel):
    resume: Optional[ExtendedResumeData] = None
    Work_Experience: Optional[List[WorkExperience]] = None
    education: Optional[Education] = None
    work_authorization: Optional[str] = None
    reference: Optional[Dict[str, str]] = None
    links: Optional[Dict[str, Dict]] = None
    notes: Optional[str] = None

```
**Additional Sections:**
- `Work Experience` - previous work engagements details including: 
    - organization name: 
    - location: 
    - employment length: 
    - role:
    - job description:
```python
class WorkExperience(BaseModel):
    org_name: str = ""
    location: str = ""
    employment_length: str = ""
    role: str = ""
    job_description: str = ""

```
---
These models can be directly integrated with _FastAPI_ or other web frameworks to serve as `request`/`response` schemas:
- Basic Example:
```python
from models import BasicResumeData, Name, Contact, JobTitle

basic_resume = BasicResumeData(
    name=Name(first_name="Éléonore", last_name="d'Aquitaine"),
    contact=Contact(email="eleanor@aquitaine.kingdom", phone="123-456-7890"),
    job_title=JobTitle(position="Queen Consort", role="Medieval Queen of England and France")
)
```
- Below is an example that creates a full resume profile for the historical figure **Eleanor of Aquitaine** 
- Although these models are designed for modern resumes, I wanted this as fun exercise of an example that uses historical data to illustrate how this type of data profile can still be structured and valid:

```python
from models import (
    Name, Contact, JobTitle,
    ExtendedResumeData, WorkExperience, Education,
    FullResume
)

# ... create an extended resume profile for Eleanor of Aquitaine:
extended_resume = ExtendedResumeData(
    name=Name(first_name="Eleanor", last_name="of Aquitaine"),
    contact=Contact(email="eleanor@aquitaine.kingdom", phone="N/A"),
    job_title=JobTitle(position="Queen Consort", role="Influential Political Leader"),
    summary=(
        "Eleanor of Aquitaine was a powerful and influential figure in medieval Europe. "
        "As Duchess of Aquitaine, she became Queen consort of both France and England, "
        "and played a key role in shaping the politics and culture of her time."
    ),
    # ... since technical skills don't apply to medieval history, we'll leave these empty:
    Programming_Languages={},
    Automation={},
    Testing={},
    Development_Tools={},
    Web_Technologies={},
    Build_Tools={},
    DevOps={},
    Microservices={},
    Databases={},
    Version_Control={},
    OS_Architecture={},
    Virtualization_Compute={},
    Network_Protocols={},
    Management_Tools={
        "Court Administration": "Expert",
        "Diplomacy": "Master",
        "Cultural Patronage": "Pioneering"
    }
)

# ... define historical work experience entries:
work_exp1 = WorkExperience(
    org_name="Kingdom of France",
    location="Aquitaine, France",
    employment_length="1137-1152",
    role="Queen Consort",
    job_description=(
        "Supported King Louis VII in governance, initiated cultural reforms, "
        "and was involved in significant historical events like the Second Crusade."
    )
)

work_exp2 = WorkExperience(
    org_name="Kingdom of England",
    location="England",
    employment_length="1154-1189",
    role="Queen Consort",
    job_description=(
        "Played a central role in the English court, influencing political decisions "
        "and nurturing the cultural and intellectual life of the realm."
    )
)

# ... define an education record based on medieval court education:
education_record = Education(
    degree="Medieval Court Education",
    location="Duchy of Aquitaine",
    majored_in="Governance, Arts, and Diplomacy"
)

# ... create a full resume profile combining all sections:
full_resume_profile = FullResume(
    resume=extended_resume,
    Work_Experience=[work_exp1, work_exp2],
    education=education_record,
    work_authorization="Royal bloodline",
    reference={
        "Medieval Chronicles": "https://en.wikipedia.org/wiki/Eleanor_of_Aquitaine"
    },
    links={
        "Historical Biography": {"url": "https://www.britannica.com/biography/Eleanor-of-Aquitaine"}
    },
    notes="Born in about 1122, Eleanor became Duchess of Aquitaine, a region in what is now south-western France, after her father’s death in 1137. The teenage Eleanor had suddenly become the most eligible bride in Europe. In 1137, Louis VI, King of France, secured Eleanor as bride to his son and heir, Prince Louis. Eleanor travelled to Bordeaux and married Louis on 25 July 1137. Within a few months of the wedding the king was dead, and Eleanor and Louis (now King Louis VII) were crowned king and queen of France on Christmas day 1137. Considered one of the most powerful and influential women in European history:"
)

# ... print the full resume profile in JSON format for inspection:
print(full_resume_profile.json(indent=4))
```
___
