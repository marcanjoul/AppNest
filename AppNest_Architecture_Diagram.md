┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                            📱 AppNestApp.swift                              │
│                         (@main - App Entry Point)                           │
│                                                                             │
│                          • Launches on app start                            │
│                          • Creates WindowGroup                              │
│                          • Loads RootView()                                 │
│                                                                             │
└──────────────────────────────────┬──────────────────────────────────────────┘
                                   │
                                   │ instantiates
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                              🏠 RootView.swift		                       │
│                          (Navigation Container)                             │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  @StateObject var viewModel = JobViewModel()  ◄─── CREATES & OWNS    │   │ 
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────┐  ┌─────────────────────────────────────┐   │
│  │   📋 Tab 1: Applications    │  │   👤 Tab 2: Profile 			   │   │
│  │                             │  │                                     │   │
│  │  NavigationStack {          │  │  NavigationStack {                  │   │
│  │    ApplicationView(         │  │    ProfileView()                    │   │
│  │      viewModel: viewModel   │  │  }                                  │   │
│  │    )                        │  │                                     │   │
│  │  }                          │  │  (placeholder - no ViewModel yet)   │   │
│  └────────────┬────────────────┘  └─────────────────────────────────────┘   │
│               │ passes ViewModel                                            │
│               │                                                             │
└───────────────┼─────────────────────────────────────────────────────────────┘
                │
                │
                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                        📱 ApplicationView.swift                             │
│                         (Main Job List Screen)                              │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  @ObservedObject var viewModel: JobViewModel  ◄─── RECEIVES          │  │
│  │  @State private var searchText = ""                                  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  Displays:                                                                  │
│  • Search bar (filters jobs)                                                │
│  • Empty state (when no jobs)                                               │
│  • ScrollView with LazyVStack                                               │
│  • [+] button in toolbar                                                    │
│                                                                             │
│  ┌─────────────────────┐         ┌──────────────────────┐                  │
│  │  ForEach loop       │────────▶│  Creates multiple    │                  │
│  │  (filtered jobs)    │         │  JobCardView         │                  │
│  └─────────────────────┘         └──────────────────────┘                  │
│            │                              │                                 │
│            │                              │ wrapped in                      │
│            │                              │ NavigationLink                  │
│            │                              ▼                                 │
│            │                     ┌─────────────────────┐                   │
│            │                     │  Navigates to:      │                   │
│            │                     │  JobDetailView      │                   │
│            │                     └─────────────────────┘                   │
│            │                                                                │
│            │ reads from                                                     │
│            ▼                                                                │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │              viewModel.applications: [JobApplication]                │  │
│  │                    (array of all jobs)                               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────┬───────────────────────────────────────────┬───────────────────┘
              │                                           │
              │ passes job data                           │ passes job + viewModel
              │                                           │
              ▼                                           ▼
┌──────────────────────────────┐          ┌──────────────────────────────────┐
│                              │          │                                  │
│   🎴 JobCardView.swift       │          │   📝 JobDetailView.swift         │
│   (Individual List Item)     │          │   (Edit/Create Form)             │
│                              │          │                                  │
│  ┌────────────────────────┐  │          │  ┌────────────────────────────┐  │
│  │ let job: JobApplication│  │          │  │ var job: JobApplication    │  │
│  └────────────────────────┘  │          │  │ @ObservedObject viewModel  │  │
│                              │          │  │                            │  │
│  Displays:                   │          │  │ @State copies of:          │  │
│  • Company logo (circle)     │          │  │   - company                │  │
│  • Position title            │          │  │   - position               │  │
│  • Company name              │          │  │   - type, status, season   │  │
│  • Pills (type/status/season)│          │  │   - dateApplied            │  │
│  • "Applied X days ago"      │          │  │   - jobNotes               │  │
│  • Chevron (→)               │          │  └────────────────────────────┘  │
│                              │          │                                  │
│  Uses:                       │          │  Contains Sections:              │
│  • Pill component (nested)   │          │  • JobInfoSection                │
│  • color(for:) helpers       │          │  • TypePickerSection             │
│  • RelativeDateFormatter     │          │  • StatusPickerSection           │
│  • Glassmorphic styling      │          │  • SeasonPickerSection           │
│                              │          │  • DateAppliedSection            │
└───────┬──────────────────────┘          │  • ResumeSection                 │
        │                                 │  • JobNotesSection               │
        │ uses                            │                                  │
        │                                 │  Each section uses:              │
        ▼                                 │  • @Binding to parent @State     │
┌──────────────────────┐                  │                                  │
│  Nested Pill struct  │                  │  On Save:                        │
│  • text: String      │                  │  ┌────────────────────────────┐  │
│  • color: Color      │                  │  │ viewModel.update(          │  │
│  • Capsule shape     │                  │  │   job: job,                │  │
│  • Bold text         │                  │  │   company: company,        │  │
└──────────────────────┘                  │  │   position: position,      │  │
                                          │  │   ...all fields            │  │
                                          │  │ )                          │  │
                                          │  │ dismiss()                  │  │
                                          │  └────────────────────────────┘  │
                                          │           │                      │
                                          └───────────┼──────────────────────┘
                                                      │
                                                      │ calls
                                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                         🧠 JobViewModel.swift                               │
│                       (Business Logic & State)                              │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  class JobViewModel: ObservableObject                               │  │
│  │                                                                      │  │
│  │    @Published var applications: [JobApplication] = []              │  │
│  │           ▲                                                          │  │
│  │           └─── Changes here notify ALL observing views              │  │
│  │                                                                      │  │
│  │    func update(job, company, position, type, status, ...)  {        │  │
│  │      if let index = applications.firstIndex(where: { $0.id == job.id }) {│
│  │        applications[index].company = company                        │  │
│  │        applications[index].position = position                      │  │
│  │        // ... update all fields                                     │  │
│  │      }                                                               │  │
│  │    }                                                                 │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  The applications array contains instances of:                              │
│                                                                             │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
                               │ stores array of
                               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                      📊 JobApplication.swift                                │
│                      (Data Models / Structures)                             │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  struct JobApplication: Identifiable                                │  │
│  │    let id: UUID                                                      │  │
│  │    var company: Company                    ◄───┐                     │  │
│  │    var position: String                        │                     │  │
│  │    var jobType: ApplicationType?        ◄──────┼───┐                 │  │
│  │    var status: ApplicationStatus?       ◄──────┼───┼───┐             │  │
│  │    var season: ApplicationSeason?       ◄──────┼───┼───┼───┐         │  │
│  │    var dateApplied: Date                       │   │   │   │         │  │
│  │    var jobNotes: String?                       │   │   │   │         │  │
│  │    var resumeFileName: String?                 │   │   │   │         │  │
│  │    var resumeBookmark: Data?                   │   │   │   │         │  │
│  └────────────────────────────────────────────────┼───┼───┼───┼─────────┘  │
│                                                   │   │   │   │            │
│  ┌────────────────────────────────────────────────┘   │   │   │            │
│  │  struct Company: Identifiable, Hashable            │   │   │            │
│  │    let id: UUID                                    │   │   │            │
│  │    var name: String                                │   │   │            │
│  │    var logoName: String                            │   │   │            │
│  │    var logoImageData: Data?                        │   │   │            │
│  └────────────────────────────────────────────────────┘   │   │            │
│                                                           │   │            │
│  ┌────────────────────────────────────────────────────────┘   │            │
│  │  enum ApplicationType: String, CaseIterable                │            │
│  │    case fullTime, partTime, contract                       │            │
│  │    case internship, Co_op, temporary                       │            │
│  └────────────────────────────────────────────────────────────┘            │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  enum ApplicationStatus: String, CaseIterable                       │   │
│  │    case toApply, applied, interview, offer, rejected                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  enum ApplicationSeason: String, CaseIterable                       │   │
│  │    case winter, spring, summer, fall                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────┬───────────────────────────────────────────────────────────┘
                  │
                  │ colors defined in extensions
                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                          🎨 PillUI.swift                                    │
│                    (Reusable UI Component)                                  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  struct SelectablePill<T>: View                                      │  │
│  │    where T: Hashable & RawRepresentable,                             │  │
│  │          T.RawValue == String                                        │  │
│  │                                                                      │  │
│  │    let option: T                                                     │  │
│  │    let isSelected: Bool                                              │  │
│  │    let color: Color                                                  │  │
│  │    let onTap: () -> Void                                             │  │
│  │                                                                      │  │
│  │    • Capsule shape                                                   │  │
│  │    • Bold text                                                       │  │
│  │    • Color opacity changes when selected                             │  │
│  │    • Haptic feedback on tap                                          │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  extension ApplicationType {                                         │  │
│  │    var color: Color {                                                │  │
│  │      switch self {                                                   │  │
│  │        case .fullTime: return .green                                 │  │
│  │        case .partTime: return .yellow                                │  │
│  │        case .internship: return .red                                 │  │
│  │        // ... etc                                                    │  │
│  │      }                                                                │  │
│  │    }                                                                  │  │
│  │  }                                                                    │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  extension ApplicationStatus { var color: Color {...} }              │  │
│  │  extension ApplicationSeason { var color: Color {...} }              │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  Used by:                                                                   │
│  • JobDetailView sections (TypePickerSection, StatusPickerSection, etc.)    │
│  • Any view that needs selectable pills                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘


                        ═══════════════════════════════
                              DATA FLOW DIAGRAM
                        ═══════════════════════════════

┌────────────────────────────────────────────────────────────────────────────┐
│                          USER INTERACTIONS                                 │
└────────────────────────────────────────────────────────────────────────────┘

  USER ACTION                    FLOW                           RESULT
  ───────────                    ────                           ──────

1. App Launch
   │
   ├─▶ AppNestApp (@main)
   │   └─▶ RootView created
   │       └─▶ JobViewModel created (@StateObject)
   │           └─▶ TabView rendered
   │               ├─▶ ApplicationView (Tab 1)
   │               └─▶ ProfileView (Tab 2)
   │
   └─▶ User sees: Applications tab with job list (or empty state)


2. Viewing Jobs
   │
   ├─▶ ApplicationView reads viewModel.applications
   │   └─▶ ForEach creates JobCardView for each job
   │       └─▶ JobCardView displays:
   │           • Company logo
   │           • Position title
   │           • Pills (type/status/season)
   │           • "Applied X days ago"
   │
   └─▶ User sees: List of job cards


3. Searching Jobs
   │
   ├─▶ User types in search bar
   │   └─▶ searchText @State updates
   │       └─▶ filteredApplications re-computes
   │           └─▶ ForEach updates with filtered list
   │               └─▶ UI re-renders
   │
   └─▶ User sees: Filtered job list (or "No results")


4. Adding New Job
   │
   ├─▶ User taps [+] button in toolbar
   │   └─▶ isPresentingNewApplication = true
   │       └─▶ Sheet presents JobDetailView
   │           └─▶ Blank job created with defaults
   │               └─▶ User fills in fields
   │                   └─▶ User taps "Save Changes"
   │                       └─▶ viewModel.applications.append(newJob)
   │                           └─▶ @Published triggers update
   │                               └─▶ ApplicationView re-renders
   │                                   └─▶ dismiss() closes sheet
   │
   └─▶ User sees: New job in list


5. Editing Existing Job
   │
   ├─▶ User taps JobCardView
   │   └─▶ NavigationLink activates
   │       └─▶ JobDetailView pushed onto stack
   │           └─▶ Form pre-populated with job data
   │               └─▶ User modifies fields (@State copies)
   │                   └─▶ User taps "Save Changes"
   │                       └─▶ viewModel.update(job: job, ...)
   │                           └─▶ Finds job by ID
   │                               └─▶ Updates all fields
   │                                   └─▶ @Published triggers update
   │                                       └─▶ ApplicationView re-renders
   │                                           └─▶ JobCardView shows new data
   │                                               └─▶ dismiss() pops back
   │
   └─▶ User sees: Updated job in list


6. Uploading Custom Logo
   │
   ├─▶ User taps logo in JobDetailView
   │   └─▶ PhotosPicker appears
   │       └─▶ User selects image
   │           └─▶ pickerItem updates
   │               └─▶ onChange triggers
   │                   └─▶ Task loads image data
   │                       └─▶ company.logoImageData = data
   │                           └─▶ Logo updates in form
   │                               └─▶ User saves
   │                                   └─▶ Custom logo persists
   │
   └─▶ User sees: Custom logo in list and detail view


7. Attaching Resume
   │
   ├─▶ User taps paperclip in ResumeSection
   │   └─▶ isShowingDocumentPicker = true
   │       └─▶ DocumentPicker sheet appears
   │           └─▶ User selects file
   │               └─▶ Security-scoped bookmark created
   │                   └─▶ resumeFileName + bookmark stored
   │                       └─▶ User saves
   │                           └─▶ Resume data persists
   │
   └─▶ User sees: Resume filename displayed


8. Selecting Type/Status/Season
   │
   ├─▶ User taps pill in picker section
   │   └─▶ onTap closure runs
   │       └─▶ withAnimation { type = newValue }
   │           └─▶ @State updates
   │               └─▶ Pill appearance changes
   │                   └─▶ ScrollViewReader auto-scrolls
   │                       └─▶ Haptic feedback fires
   │
   └─▶ User sees: Selected pill highlighted, scrolled into view


                        ═══════════════════════════════
                           COMPONENT RELATIONSHIPS
                        ═══════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│                         OWNERSHIP HIERARCHY                             │
└─────────────────────────────────────────────────────────────────────────┘

AppNestApp
  └── RootView
      ├── JobViewModel (OWNER - @StateObject)
      │   └── applications: [JobApplication]
      │
      ├── Tab 1: ApplicationView
      │   ├── Receives: viewModel (@ObservedObject)
      │   ├── Owns: searchText, isPresentingNewApplication (@State)
      │   │
      │   └── Children:
      │       ├── ForEach → JobCardView (receives individual job)
      │       │   └── Nested: Pill component
      │       │
      │       └── NavigationLink → JobDetailView
      │           ├── Receives: job, viewModel
      │           ├── Owns: @State copies of all editable fields
      │           │
      │           └── Subviews:
      │               ├── JobInfoSection
      │               │   └── Receives: @Binding to company, position
      │               │
      │               ├── TypePickerSection
      │               │   ├── Receives: @Binding to type
      │               │   └── Uses: SelectablePill (from PillUI.swift)
      │               │
      │               ├── StatusPickerSection
      │               │   ├── Receives: @Binding to status
      │               │   └── Uses: SelectablePill
      │               │
      │               ├── SeasonPickerSection
      │               │   ├── Receives: @Binding to season
      │               │   └── Uses: SelectablePill
      │               │
      │               ├── DateAppliedSection
      │               │   └── Receives: @Binding to dateApplied
      │               │
      │               ├── ResumeSection
      │               │   └── Callbacks: onPick, onClear
      │               │
      │               └── JobNotesSection
      │                   └── Receives: @Binding to jobNotes
      │
      └── Tab 2: ProfileView
          └── (Independent, no data dependencies yet)


┌─────────────────────────────────────────────────────────────────────────┐
│                      STATE MANAGEMENT PATTERN                           │
└─────────────────────────────────────────────────────────────────────────┘

SOURCE OF TRUTH:
┌────────────────────────────────────────┐
│  JobViewModel.applications             │  ◄─── Single source of truth
│  @Published var applications = []      │
└────────────────────────────────────────┘
             │
             │ observed by (@ObservedObject)
             │
    ┌────────┴────────┐
    ▼                 ▼
ApplicationView   JobDetailView
    │                 │
    │ owns            │ owns
    ▼                 ▼
@State local     @State local copies
   state         (company, position, etc.)
    │                 │
    │ passes          │ passes
    ▼                 ▼
JobCardView      Subview sections
(read-only)      (via @Binding)


┌─────────────────────────────────────────────────────────────────────────┐
│                        IMPORT DEPENDENCIES                              │
└─────────────────────────────────────────────────────────────────────────┘

AppNestApp.swift
  └── import SwiftUI

RootView.swift
  └── import SwiftUI

JobApplication.swift
  └── import Foundation

JobViewModel.swift
  └── import SwiftUI

PillUI.swift
  ├── import SwiftUI
  └── import UIKit (conditionally via #if canImport)

ApplicationView.swift
  └── import SwiftUI

JobCardView.swift
  ├── import SwiftUI
  └── import UIKit (conditionally)

JobDetailView.swift
  ├── import SwiftUI
  ├── import UniformTypeIdentifiers (for file types)
  ├── import PhotosUI (for PhotosPicker)
  └── import UIKit (conditionally)

ProfileView.swift
  └── import SwiftUI


═══════════════════════════════════════════════════════════════════════════
                           KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════════════

1. SINGLE SOURCE OF TRUTH
   • JobViewModel.applications is the ONE place jobs are stored
   • All views read/write from this shared state
   • Changes propagate automatically via @Published

2. UNIDIRECTIONAL DATA FLOW
   • Data flows DOWN (parent → child via parameters)
   • Events flow UP (child → parent via callbacks/bindings)
   • ViewModel is the central hub

3. STATE OWNERSHIP
   • RootView OWNS ViewModel (@StateObject)
   • Child views OBSERVE ViewModel (@ObservedObject)
   • Local UI state stays in views (@State)

4. COMPONENT REUSABILITY
   • SelectablePill works with ANY enum
   • JobCardView is used in list
   • Sections in JobDetailView are extractable

5. SEPARATION OF CONCERNS
   • Models (JobApplication.swift) = Data structure
   • ViewModel (JobViewModel.swift) = Business logic
   • Views (all others) = UI presentation