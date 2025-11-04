import SwiftUI

struct CommunityTabScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Image(.communities)
                        
                    Group {
                        Text("Stay connected with a community")
                            .font(.title2)
                        
                        Text("Communities brings member together in topic-based groups. Any community you're added to will appear here.")
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 16)
                    
                    Button("See example communities") {}
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                    
                    createNewCommunityButton()
                        .padding()
                }
            }
            .navigationTitle("Communities")
        }
    }
    
    //  MARK: - Private
    private func createNewCommunityButton() -> some View {
        Button {
            
        } label: {
            Label("New Community", systemImage: "plus")
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .padding(10)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

#Preview {
    CommunityTabScreen()
}
