import Foundation
import Combine
import PhotosUI
import SwiftUI

@MainActor
final class ChatroomViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var textMessage = ""
    @Published var messages: [Message] = []
    @Published var showPhotoPickerView = false
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachments] = []
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false, nil)
    private var currentUser: UserItem?
    private var subscriptions = Set<AnyCancellable>()
    private(set) var channel: Channel
    
    private let audioRecorderService = AudioRecorderService()
    
    var showPhotoPickerPreview: Bool { !mediaAttachments.isEmpty || !photoPickerItems.isEmpty }
    
    //  MARK: - Init & Deinit
    init(_ channel: Channel) {
        self.channel = channel
        listenAuthstate()
        onPhotoPickerSelection()
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
    }
    
    //  MARK: - Internal & Private
    func sendMessage() {
        guard let currentUser else { return }
        MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) { [weak self] in
            self?.textMessage = ""
        }
    }
    
    private func listenAuthstate() {
        AuthenticationService.shared.authState.receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                guard let self else { return }
                switch authState {
                case .loggedIn(let loggedInUser):
                    self.currentUser = loggedInUser
                    
                    if self.channel.allMembersFetched {
                        self.getMessages()
                    } else {
                        self.getAllChannelMembers()
                    }
                default: break
                }
            }.store(in: &subscriptions)
    }
    
    private func getMessages() {
        MessageService.getMessages(for: channel) { [weak self] messages in
            self?.messages = messages
            print(messages.map({ $0.text }))
        }
    }
    
    private func getAllChannelMembers() {
        guard let currentUser else { return }
        let alreadyFetchedMembers = channel.members.compactMap { $0.uid }
        var memberUidsToFetch = channel.membersUids.filter { !alreadyFetchedMembers.contains($0) }
        memberUidsToFetch = memberUidsToFetch.filter { $0 != currentUser.uid }
        UserService.getUsers(with: memberUidsToFetch) { [weak self] userNode in
            guard let self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getMessages()
        }
    }
    
    func handleTextInputArea(_ action: TextInputAreaView.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPickerView = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecorder()
        }
    }
    
    private func toggleAudioRecorder() {
        if audioRecorderService.isRecording {
            audioRecorderService.stopRecording { [weak self] audioURL, audioDuration in
                self?.createAudioAttachment(from: audioURL, audioDuration)
            }
        } else {
            audioRecorderService.startRecording()
        }
    }
    
    private func createAudioAttachment(from audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachments(id: id, type: .audio)
        mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self else { return }
            self.mediaAttachments.removeAll()
            Task { await self.parsePhotoPickerItems(photoItems) }
        }.store(in: &subscriptions)
    }
    
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for photoItem in photoPickerItems {
            if photoItem.isVideo {
                if let video = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self),
                   let thumbnailImage = try? await video.url.generateVideoThumbnail(),
                   let itemIdentifier = photoItem.itemIdentifier {
                    let videoAttachments = MediaAttachments(id: itemIdentifier, type: .video(thumbnailImage, video.url))
                    self.mediaAttachments.insert(videoAttachments, at: 0)
                }
            } else {
                guard let data = try? await photoItem.loadTransferable(type: Data.self),
                      let thumbnailImage = UIImage(data: data),
                      let itemIdentifier = photoItem.itemIdentifier else { return }
                let photoAttachments = MediaAttachments(id: itemIdentifier, type: .photo(thumbnailImage))
                self.mediaAttachments.insert(photoAttachments, at: 0)
            }
        }
    }
    
    func dismissMediaPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
    }
    
    private func showMediaPlayer(_ fileURL: URL) {
        videoPlayerState.show = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }
    
    func handleMediaAttachmentPreview(_ action: MediaAttachmentsPreview.UserAction) {
        switch action {
        case .play(let attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediaPlayer(fileURL)
        case .remove(let attachment):
            remove(attachment)
        }
    }
    
    private func remove(_ attachment: MediaAttachments) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == attachment.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)
        guard let photoPickerIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == attachment.id }) else { return }
        photoPickerItems.remove(at: photoPickerIndex)
    }
}
