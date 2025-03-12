**MongoDB CLI Commands for Viewing Data**

### **1. View All Documents in a Collection**
```sh
db.collection_name.find().pretty()
```
This will return all documents in `collection_name` formatted for better readability.

---

### **2. Find a Document by Name**
```sh
db.collection_name.find({ "resume.name.first_name": "William" }).pretty()
```
This searches for documents where the `first_name` field inside `resume.name` is `"William"`.

---

### **3. Find a Document by ID**
```sh
db.collection_name.find({ "_id": ObjectId("your_object_id_here") }).pretty()
```
Replace `"your_object_id_here"` with the actual `_id` from your document.

---

### **4. Search by Any JSON Key**
```sh
db.collection_name.find({ "resume.contact.email": "email@example.com" }).pretty()
```
Replace `"email@example.com"` with the actual email value you want to search for.

---

### **5. List All Unique First Names**
```sh
db.collection_name.distinct("resume.name.first_name")
```
This will return a list of all unique first names stored in the collection.

---

### **6. Count Documents Matching a Query**
```sh
db.collection_name.countDocuments({ "resume.job_title.position": "President" })
```
This will return the count of documents where `position` is `"President"`.

---

### **7. Limit the Number of Results**
```sh
db.collection_name.find().limit(5).pretty()
```
This will return only the first **5** documents.

---

**Notes:**
- Replace `collection_name` with the actual collection you are querying.
- Use `pretty()` for better readability of JSON results.
- Use `ObjectId()` when searching by `_id`.

