# AppNest: Internship & Job Tracker App

AppNest is an iOS app built to help keep track of jobs that are applied to, it has the ability to manually add a past job, or even paste a job applied to from an email (using AI)! An effort made by me to enhance my developer knowledge in order to be ready for SWE internships.


> Designed to be the ultimate job search companion for students and early-career professionals.

---

## Screenshots/Demos
Home & Job Details Views (In Progress Still)

<img src="https://github.com/user-attachments/assets/be1b7c9d-d3b7-4807-afca-35adeaf825b1" alt="0929 demo" width="180"/>


---

## Key Features

### 1. **Parse Job Emails**
* Users can paste job-related emails into a parser view
* AI extracts details using a custom prompt
* Saves entry using current date as fallback timestamp
* Uses **OpenAI API** to extract:

  * Company
  * Position Title
  * Application Status
  * & more
* Automatically saves to your job tracker

### 2. **Manual Entry (MVP Ready)**

* Users can manually enter their applications to the tracker
* They can manually adjust their input at any time
* they can upload their tailored resume for every job

### 3. **Smart Filtering & Status Tags**

* Custom status options: `To Apply`, `Applied`, `Interview`, `Offer`, `Rejected`
* Filter by role, company, date, or status

---

## App Structure

### Tabs

* **Home**: List of job/internship entries (sortable + searchable)
* **Add**: Paste email body / manual entry
* **Profile**: Stats, export CSV, upload defualt resume

---

## Technologies Used

* **SwiftUI** for UI
* **LLM API (TBD)** for parsing and tips

---

## License

MIT License  

Copyright (c) 2025 Mark Anjoul  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

