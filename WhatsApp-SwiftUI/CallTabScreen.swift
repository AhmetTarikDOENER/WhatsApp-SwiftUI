import SwiftUI

struct CallTabScreen: View {
    
    @State private var searchText = ""
    @State private var callHistory = CallHistory.all
    
    var body: some View {
        NavigationStack {
            List {
                
            }
            .navigationTitle("Calls")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavigationBarItem()
                principalNavigationBarItem()
                trailingNavigationBarItem()
            }
        }
    }
}

//  MARK: - CallTabScreen+Extension
extension CallTabScreen {
    
    private enum CallHistory: String, CaseIterable, Identifiable {
        case all, missed
        var id: String { return rawValue }
    }
    
    @ToolbarContentBuilder
    private func leadingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Edit") { }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "phone.arrow.up.right")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func principalNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $callHistory) {
                ForEach(CallHistory.allCases) { history in
                    Text(history.rawValue.capitalized)
                        .tag(history)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
        }
    }
}

#Preview {
    CallTabScreen()
}
