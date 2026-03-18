import SwiftUI
import SwiftData

struct EmailParserView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var emailText: String = ""
    @State private var parsedResult: EmailParser.ParsedResult? = nil
    @State private var isParsing = false
    @State private var showingConfirmation = false
    
    private let parser = EmailParser()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: Input Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Paste Email", systemImage: "envelope.open.fill")
                            .font(.title3.weight(.semibold))
                        
                        Text("Paste a job application confirmation email and we'll extract the details automatically.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        ZStack(alignment: .topLeading) {
                            if emailText.isEmpty {
                                Text("Paste your email here...")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                            }
                            TextEditor(text: $emailText)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 200)
                                .padding(8)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                    
                    // Parse Button
                    Button {
                        parseEmail()
                    } label: {
                        HStack {
                            if isParsing {
                                ProgressView()
                                    .tint(.white)
                            }
                            Image(systemName: "sparkles")
                            Text("Parse Email")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(emailText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isParsing)
                    
                    // MARK: Results Section
                    if let result = parsedResult {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Extracted Details", systemImage: "checkmark.circle.fill")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.green)
                            
                            ResultRow(label: "Company", value: result.companyName ?? "Not detected", icon: "building.2")
                            ResultRow(label: "Position", value: result.position ?? "Not detected", icon: "briefcase")
                            ResultRow(label: "Status", value: result.status?.rawValue ?? "Not detected", icon: "flag")
                            ResultRow(
                                label: "Date",
                                value: result.dateApplied.map {
                                    $0.formatted(date: .abbreviated, time: .omitted)
                                } ?? "Not detected",
                                icon: "calendar"
                            )
                            
                            Button {
                                saveApplication()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add to Applications")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .controlSize(.large)
                            .disabled(result.companyName == nil && result.position == nil)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Parse Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        #if canImport(UIKit)
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                        #endif
                    }
                }
            }