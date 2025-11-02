import SwiftUI

struct UpdatesTabScreen: View {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                StatusSectionHeaderView()
                    .listRowBackground(Color.clear)
                
                StatusSectionView()
                
                Section {
                    RecentUpdatesItemView()
                } header: {
                    Text("Recent Updates")
                }
                
                Section {
                    ChannelListView()
                } header: {
                    channelListViewSectionHeader()
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Updates")
            .searchable(text: $searchText)
        }
    }
    
    //  MARK: - Private
    private func channelListViewSectionHeader() -> some View {
        HStack {
            Text("Channels")
                .bold()
                .font(.title3)
                .textCase(nil)
                .foregroundStyle(.whatsAppBlack)
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "plus")
                    .padding(7)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
        }
    }
}

//  MARK: - UpdatesTabScreen+Extension
private extension UpdatesTabScreen {
    enum Constants {
        static let imageDimension: CGFloat = 55
    }
}

//  MARK: - StatusSectionHeader
private struct StatusSectionHeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "circle.dashed")
                .foregroundStyle(.blue)
                .imageScale(.large)
            
            Text("Use status to share photos, text, and videos that disappear in 24 hours.") + Text(" ") +
            Text("Status Privacy")
                .foregroundColor(.blue).bold()
            
            Image(systemName: "xmark")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(.whatsAppWhite)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

//  MARK: - StatusSection
private struct StatusSectionView: View {
    var body: some View {
        HStack {
            Circle()
                .frame(
                    width: UpdatesTabScreen.Constants.imageDimension,
                    height: UpdatesTabScreen.Constants.imageDimension
                )
            
            VStack(alignment: .leading) {
                Text("My Status")
                    .font(.callout)
                    .bold()
                
                Text("Add to my status")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            cameraButton()
            
            pencilButton()
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera.fill")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        }
    }
    
    private func pencilButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "pencil")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        }
    }
}

//  MARK: - RecentUpdatesItemView
private struct RecentUpdatesItemView: View {
    var body: some View {
        HStack {
            Circle()
                .frame(
                    width: UpdatesTabScreen.Constants.imageDimension,
                    height: UpdatesTabScreen.Constants.imageDimension
                )
            
            VStack(alignment: .leading) {
                Text("Tim Cook")
                    .font(.callout)
                    .bold()
                
                Text("1hr")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
            }
        }
    }
}

//  MARK: - ChannelListView
private struct ChannelListView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stay updated on topics that matter to you. Find channels to follow below.")
                .foregroundStyle(.gray)
                .font(.callout)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0 ..< 5) { _ in
                        ChannelListItemView()
                    }
                }
            }
            
            Button("Explore More") { }
                .tint(.blue)
                .bold()
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
                .padding(.vertical)
        }
    }
}

//  MARK: - ChannelListItemView
private struct ChannelListItemView: View {
    var body: some View {
        VStack {
            Circle()
                .frame(
                    width: UpdatesTabScreen.Constants.imageDimension,
                    height: UpdatesTabScreen.Constants.imageDimension
                )
            
            Text("Apple News")
            
            Button {
                
            } label: {
                Text("Follow")
                    .bold()
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(.blue.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
    }
}

#Preview {
    UpdatesTabScreen()
}
