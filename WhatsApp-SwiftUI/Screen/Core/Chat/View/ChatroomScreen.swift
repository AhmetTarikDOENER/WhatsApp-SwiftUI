import SwiftUI
import PhotosUI
import StreamVideoSwiftUI
import StreamVideo

struct ChatroomScreen: View {
    
    //  MARK: - Properties
    @StateObject private var viewModel: ChatroomViewModel
    @StateObject private var audioMessagePlayer = AudioMessagePlayer()
    @EnvironmentObject private var callViewModel: CallViewModel
    let channel: Channel
    
    //  MARK: - Init
    init(channel: Channel) {
        self.channel = channel
        _viewModel = StateObject(wrappedValue: ChatroomViewModel(channel))
    }
    
    var body: some View {
        MessageListView(viewModel)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                leadingNavigationBarItem()
                trailingNavigationBarItemGroup()
            }
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
            .safeAreaInset(edge: .bottom) {
                bottomSafeAreaView()
                    .background(.whatsAppWhite)
            }
            .photosPicker(
                isPresented: $viewModel.showPhotoPickerView,
                selection: $viewModel.photoPickerItems,
                maxSelectionCount: 6,
                photoLibrary: .shared()
            )
            .fullScreenCover(isPresented: $viewModel.videoPlayerState.show) {
                if let player = viewModel.videoPlayerState.player {
                    MediaPlayerView(player: player) {
                        viewModel.dismissMediaPlayer()
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.showPhotoPickerPreview)
            .environmentObject(audioMessagePlayer)
    }
    
    //  MARK: - Private
    private func bottomSafeAreaView() -> some View {
        VStack(spacing: 0) {
            Divider()
            
            if viewModel.showPhotoPickerPreview {
                MediaAttachmentsPreview(mediaAttachments: viewModel.mediaAttachments) { action in
                    viewModel.handleMediaAttachmentPreview(action)
                }
                
                Divider()
            }
            
            TextInputAreaView(
                textMessage: $viewModel.textMessage,
                isRecording: $viewModel.isRecording,
                elapsedTime: $viewModel.elapsedTime,
                disableSendButton: viewModel.disableSendButton) { action in
                    viewModel.handleTextInputArea(action)
                }
        }
    }
    
    private func startVideoCall() {
        guard callViewModel.call == nil else { return }
        
        callViewModel.joinCall(callType: .default, callId: "E6FmZCTNbVa3V7T6whfpT")
    }
}

//  MARK: - ChatroomScreen+Extension
extension ChatroomScreen {
    @ToolbarContentBuilder
    private func leadingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                CircularProfileImageView(channel, size: .mini)
                
                Text(truncatedChannelTitle)
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavigationBarItemGroup() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                startVideoCall()
            } label: {
                Image(systemName: "video")
            }
            
            Button {
                
            } label: {
                Image(systemName: "phone")
            }
        }
    }
    
    private var truncatedChannelTitle: String {
        let maxChar = 25
        let trailingChars = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChars)
        
        return title
    }
}

#Preview {
    NavigationStack {
        ChatroomScreen(channel: .placeholder)
    }
}
