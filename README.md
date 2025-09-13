# AppNest: Your AI-Powered Internship & Job Tracker

AppNest is an AI-powered iOS app with Firebase backend, using MVVM architecture to separate UI, logic, and data. It automates and streamlines your job and internship search. When you apply to a job and receive a confirmation email, AppNest detects it, parses the details using AI, adds it to your tracker, and notifies you — all automatically. Additionally, it has the ability to manually add a past job, or even paste a job applied to from an email! An effort made by me to enhance my developer knowledge in order to be ready for SWE internships.


> Designed to be the ultimate job search companion for students and early-career professionals.

---

## Screenshots

*Coming soon...*

---

## Key Features

### 1. **Auto-Parse Job Emails (AI + Notifications)**

* Detects confirmation emails from job applications
* Uses **OpenAI API** to extract:

  * Company
  * Position Title
  * Application Status
  * & more
* Automatically saves to your job tracker
* Sends a **push notification**: *"New job added: Meta - Software Engineer Intern"*

### 2. **Manual Entry (MVP Ready)**

* Users can manually enter their applications to the tracker
* They can manually adjust their input at any time
* they can upload their tailored resume for every job


### 3. **Manual Email Paste**

* Users can paste job-related emails into a parser view
* AI extracts details using a custom prompt
* Saves entry using current date as fallback timestamp

### 4. **Link Autofill**

* Paste a job listing URL
* Extracts company and role via metadata / possible LLM summarization

### 5. **Smart Filtering & Status Tags**

* Custom status options: `Wishlist`, `Applied`, `Interview`, `Offer`, `Rejected`
* Filter by role, company, date, or status
  
### 6. **AI Cover Letter/Resume Tips** *(Stretch Goal)*

* Summarizes job description
* Suggests custom resume tips
* Generates starter sentences for cover letters
* Generates getting-ready for interview tips


### 7. **Deadline Tracking + Alerts**

* Add application deadlines
* Optional reminders to apply

---

## App Structure

### Tabs

* **Home**: List of job/internship entries (sortable + searchable)
* **Add**: Paste email / paste link / manual entry
* **Profile**: Stats, most-applied companies, export CSV, upload defualt resume

---

## Technologies Used

* **SwiftUI** for UI
* **LLM API (TBD)** for parsing and tips
* **UserNotifications** for local push alerts
* **Firebase** for sync
* **Gmail API** for real-time email parsing

---

## Future Roadmap

* [ ] Full Gmail integration (OAuth + auto-sync)
* [ ] Interview tracker per job
* [ ] Export job history as PDF or CSV
* [ ] Stats & analytics dashboard

---

## 📖 License

MIT License.
