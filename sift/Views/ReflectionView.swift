import SwiftUI

struct ReflectionView: View {
    let practiceName: String
    let onSave: (Bool?, String?) -> Void

    @State private var wasHelpful: Bool? = nil
    @State private var notes: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text(practiceName)
                    .font(.headline)

                Divider()
            }

            reflectionForm
        }
        .padding()
    }

    private var reflectionForm: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(spacing: 6) {
                Text("Did it help?")
                    .font(.title3)
            }

            HStack(spacing: 24) {
                Button {
                    wasHelpful = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(wasHelpful == true ? .green : .secondary)
                        Text("Helped")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        wasHelpful == true
                            ? Color.green.opacity(0.1)
                            : Color(.systemGray6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    wasHelpful = false
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(wasHelpful == false ? .orange : .secondary)
                        Text("Didn't help")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        wasHelpful == false
                            ? Color.orange.opacity(0.1)
                            : Color(.systemGray6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes (optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("How was it?", text: $notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            }

            HStack(spacing: 12) {
                Button {
                    onSave(nil, nil)
                } label: {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onSave(wasHelpful, notes.isEmpty ? nil : notes)
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
