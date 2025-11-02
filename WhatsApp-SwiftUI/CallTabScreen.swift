import SwiftUI

struct CallTabScreen: View {
    
    @State private var searchText = ""
    @State private var callHistory = CallHistory.all
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    CreateCallLinkSectionView()
                }
                
                Section {
                    ForEach(0 ..< 12, id: \.self) { _ in
                        RecentCallHistoryItemView()
                    }
                } header: {
                    Text("Recent")
                        .textCase(nil)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.whatsAppBlack)
                }
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

//  MARK: - CreateCallLinkSectionView
private struct CreateCallLinkSectionView: View {
    var body: some View {
        HStack {
            Image(systemName: "link")
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(Circle())
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading) {
                Text("Create a Call Link")
                    .foregroundStyle(.blue)
                    
                Text("Share a link for your WhatsApp call")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
    }
}

//  MARK: - RecentCallHistoryItemView
private struct RecentCallHistoryItemView: View {
    var body: some View {
        HStack {
            HStack {
                Circle()
                    .frame(width: 45, height: 45)
                
                recentsCallInfoTextView()
                
                Spacer()
                
                Text("Yesterday")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16))
                
                Image(systemName: "info.circle")
            }
        }
    }
    
    //  MARK: - Private
    private func recentsCallInfoTextView() -> some View {
        VStack(alignment: .leading) {
            Text("Tim Cook")
                .font(.headline)
            
            HStack(spacing: 5) {
                Image(systemName: "phone.arrow.up.right.fill")
                
                Text("Outgoing")
            }
            .font(.system(size: 14))
            .foregroundStyle(.gray)
        }
    }
}

#Preview {
    CallTabScreen()
}
