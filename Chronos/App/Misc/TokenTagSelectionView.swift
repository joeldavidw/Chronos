import AlertKit
import Factory
import SwiftData
import SwiftUI

struct TokenTagsSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @Binding var selectedTags: [String]

    private let stateService = Container.shared.stateService()

    @State private var showTagCreationSheet: Bool = false

    var body: some View {
        VStack {
            List {
                Button {
                    showTagCreationSheet = true
                } label: {
                    HStack {
                        Label("New Tag", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
                }
                .contentShape(Rectangle())
                .sheet(isPresented: $showTagCreationSheet) {
                    NavigationStack {
                        TokenTagsCreationView(selectedTags: $selectedTags)
                    }
                }

                ForEach(stateService.tags, id: \.self) { tag in
                    Button {
                        if selectedTags.contains(tag) {
                            selectedTags.removeAll { $0 == tag }
                        } else {
                            selectedTags.append(tag)
                        }
                    } label: {
                        HStack {
                            Text(tag)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            Spacer()
                            if selectedTags.contains(tag) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Choose Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TokenTagsCreationView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedTags: [String]

    private let stateService = Container.shared.stateService()

    @State private var newTag: String = ""
    @State private var verified: Bool = false

    var body: some View {
        Form {
            Section {
                TextField(text: $newTag, prompt: Text("Examples: Personal, Work")) {
                    Text("Examples: Personal, Work")
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("New Tag")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button("Cancel", action: {
            dismiss()
        }))
        .navigationBarItems(trailing: Button("Done", action: {
            stateService.tags.append(newTag)
            selectedTags.append(newTag)
            dismiss()
        })
        .disabled(!isValid))
    }

    var isValid: Bool {
        let tempTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let isNotEmpty = !tempTag.isEmpty
        let isUnique = !stateService.tags.map { $0.lowercased() }.contains(tempTag)
        let hasValidCharacters = tempTag.range(of: "^[\\p{L}0-9_\\s\\p{P}\\p{S}]+$", options: .regularExpression) != nil

        return isNotEmpty && isUnique && hasValidCharacters
    }
}
