import SwiftUI

struct ChatPartnerPickerView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(ChatPartnerPickerOptions.allCases) { option in
                    Label(option.title, systemImage: option.iconName)
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//  MARK: - ChatPartnerPickerOptions
fileprivate enum ChatPartnerPickerOptions: String, CaseIterable, Identifiable {
    case newGroup = "New Group"
    case newContact = "New Contact"
    case newCommunity = "New Community"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var iconName: String {
        switch self {
        case .newGroup: return "person.2.fill"
        case .newContact: return "person.fill.badge.plus"
        case .newCommunity: return "person.3.fill"
        }
    }
}

#Preview {
    ChatPartnerPickerView()
}
