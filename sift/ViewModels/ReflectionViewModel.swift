import Foundation

@Observable
final class ReflectionViewModel {

    enum HelpfulnessOption: CaseIterable {
        case helped, aLittle, notReally

        var label: String {
            switch self {
            case .helped:    return "Helped"
            case .aLittle:   return "A little"
            case .notReally: return "Not really"
            }
        }

        var wasHelpful: Bool? {
            switch self {
            case .helped:    return true
            case .aLittle:   return nil
            case .notReally: return false
            }
        }
    }

    var selectedHelpfulness: HelpfulnessOption? = nil
    var notes: String = ""

    var wasHelpfulForSave: Bool? {
        selectedHelpfulness?.wasHelpful
    }

    var notesForSave: String? {
        notes.isEmpty ? nil : notes
    }
}
