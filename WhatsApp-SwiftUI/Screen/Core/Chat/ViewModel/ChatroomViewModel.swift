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
    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var scrollToBottomRequest: (scroll: Bool, isAnimated: Bool) = (false, false)
    @Published var isPaginating = false
    private var currentUser: UserItem?
    private var subscriptions = Set<AnyCancellable>()
    private(set) var channel: Channel
    private var lastCursor: String?
    private var firstMessage: Message?
    
    private let audioRecorderService = AudioRecorderService()
    
    var showPhotoPickerPreview: Bool { !mediaAttachments.isEmpty || !photoPickerItems.isEmpty }
    
    var disableSendButton: Bool { mediaAttachments.isEmpty && textMessage.isEmptyOrWhitespace }
    
    var isPaginatable: Bool { lastCursor != firstMessage?.id }
    
    private var isDebugModeEnabled: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    //  MARK: - Init & Deinit
    init(_ channel: Channel) {
        self.channel = channel
        listenAuthstate()
        onPhotoPickerSelection()
        setupAudioRecorderListener()
        
        if isDebugModeEnabled {
            messages = Message.stubMessages
        }
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
        audioRecorderService.tearDown()
    }
    
    //  MARK: - Internal & Private
    func sendMessage() {
        if mediaAttachments.isEmpty {
            sendTextMessage(text: textMessage)
        } else {
            sendMultipleMediaMessages(textMessage, attachments: mediaAttachments)
            clearTextInputAreaAndRemoveItems()
        }
    }
    
    private func sendTextMessage(text: String) {
        guard let currentUser else { return }
        MessageService.sendTextMessage(to: channel, from: currentUser, text) { [weak self] in
            self?.textMessage = ""
        }
    }
    
    private func clearTextInputAreaAndRemoveItems() {
        textMessage = ""
        mediaAttachments.removeAll()
        photoPickerItems.removeAll()
        UIApplication.dismissKeyboard()
    }
    
    private func scrollToBottom(isAnimated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.isAnimated = isAnimated
    }
    
    private func sendMultipleMediaMessages(_ text: String, attachments: [MediaAttachments]) {
        for (index, attachment) in attachments.enumerated() {
            let textMessage = index == 0 ? text : ""
            switch attachment.type {
            case .photo: sendPhotoMessage(text: textMessage, attachment)
            case .video: sendVideoMessage(text: textMessage, attachment)
            case .audio: sendAudioMessage(text: textMessage, attachment)
            }
        }
    }
    
    private func sendPhotoMessage(text: String, _ attachment: MediaAttachments) {
        uploadImageToStorageBucket(attachment) { [weak self] imageURL in
            guard let self, let currentUser else { return }
            let uploadParemeters = MediaMessageUploadParameters(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                thumbnailURL: imageURL.absoluteString,
                sender: currentUser
            )
            
            MessageService.sendMediaMessage(to: channel, parameters: uploadParemeters) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
        }
    }
    
    private func sendVideoMessage(text: String, _ attachment: MediaAttachments) {
        /// Uploads the video file to the Storage
        uploadFileToStorageBucket(for: .videoMessage, attachment) { [weak self] videoURL in
            /// Uploads the video thumbnail
            self?.uploadImageToStorageBucket(attachment) { [weak self] thumbnailURL in
                guard let self, let currentUser else { return }
                
                let uploadParameters = MediaMessageUploadParameters(
                    channel: self.channel,
                    text: text,
                    type: .video,
                    attachment: attachment,
                    thumbnailURL: thumbnailURL.absoluteString,
                    videoURL: videoURL.absoluteString,
                    sender: currentUser,
                )
                /// Saves the metadata and urls to the db
                MessageService.sendMediaMessage(to: channel, parameters: uploadParameters) { [weak self] in
                    self?.scrollToBottom(isAnimated: true)
                }
            }
        }
    }
    
    private func sendAudioMessage(text: String, _ attachment: MediaAttachments) {
        guard let audioDuration = attachment.audioDuration, let currentUser else { return }
        uploadFileToStorageBucket(for: .audioMessage, attachment) { [weak self] fileURL in
            guard let self else { return }
            let uploadParameters = MediaMessageUploadParameters(
                channel: self.channel,
                text: text,
                type: .audio,
                attachment: attachment,
                sender: currentUser,
                audioURL: fileURL.absoluteString,
                audioDuration: audioDuration
            )
            
            MessageService.sendMediaMessage(to: self.channel, parameters: uploadParameters) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
            
            if !text.isEmptyOrWhitespace {
                self.sendTextMessage(text: text)
            }
        }
    }

    private func uploadImageToStorageBucket(
        _ attachment: MediaAttachments,
        completion: @escaping(_ imageURL: URL) -> Void
    ) {
        FirebaseUploader.uploadImage(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
            case .success(let imageURL):
                completion(imageURL)
            case .failure(let error):
                print("❌ ChatroomViewModel -> Failed to upload image to the Storage Bucket: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Image uploading progress: \(progress)")
        }
    }
    
    private func uploadFileToStorageBucket(
        for uploadType: FirebaseUploader.UploadType,
        _ attachment: MediaAttachments,
        completion: @escaping(_ fileURL: URL) -> Void
    ) {
        guard let fileURLToUpload = attachment.fileURL else { return }
        FirebaseUploader.uploadFile(for: uploadType, fileURL: fileURLToUpload) { result in
            switch result {
            case .success(let fileURL):
                completion(fileURL)
            case .failure(let error):
                print("❌ ChatroomViewModel -> Failed to upload file to the Storage Bucket: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("File uploading progress: \(progress)")
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
                        self.getHistoricalMessages()
                    } else {
                        self.getAllChannelMembers()
                    }
                default: break
                }
            }.store(in: &subscriptions)
    }
    
    func paginateMoreMessages() {
        guard isPaginatable else {
            isPaginating = false
            return
        }
        
        getHistoricalMessages()
    }
    
    private func observeForNewMessages() {
        MessageService.observeForNewMessages(of: channel) { [weak self] newMessage in
            self?.messages.append(newMessage)
            self?.scrollToBottom(isAnimated: false)
        }
    }
    
    private func getHistoricalMessages() {
        isPaginating = lastCursor != nil
        MessageService.getHistoricalMessages(for: channel, lastCursor: lastCursor, pageSize: 7) { [weak self] messageNode in
            if self?.lastCursor == nil {
                self?.getFirstMessage()
                self?.observeForNewMessages()
            }
            self?.messages.insert(contentsOf: messageNode.messages, at: 0)
            self?.lastCursor = messageNode.lastCursor
            self?.scrollToBottom(isAnimated: false)
            self?.isPaginating = false
        }
    }
    
    private func getFirstMessage() {
        MessageService.getTheFirstMessage(of: channel) { [weak self] firstMessage in
            self?.firstMessage = firstMessage
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
            self.getHistoricalMessages()
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
        let audioAttachment = MediaAttachments(id: id, type: .audio(audioURL, audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self else { return }
            let audioRecordings = mediaAttachments.filter { $0.type == .audio(.stubURL, .stubTimeInterval) }
            self.mediaAttachments = audioRecordings
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
    
    func showMediaPlayer(_ fileURL: URL) {
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
            guard let fileURL = attachment.fileURL else { return }
            if attachment.type == .audio(.stubURL, .stubTimeInterval) {
                audioRecorderService.deleteRecording(at: fileURL)
            }
        }
    }
    
    private func remove(_ attachment: MediaAttachments) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == attachment.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)
        guard let photoPickerIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == attachment.id }) else { return }
        photoPickerItems.remove(at: photoPickerIndex)
    }
    
    private func setupAudioRecorderListener() {
        audioRecorderService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecording = isRecording
            }.store(in: &subscriptions)
        
        audioRecorderService.$elapsedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elapsedTime in
                self?.elapsedTime = elapsedTime
            }.store(in: &subscriptions)
    }
    
    func isNewDayToShowRelativeTimestamp(for message: Message, at index: Int) -> Bool {
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        
        return !message.timestamp.isSameDay(as: priorMessage.timestamp)
    }
    
    func showMessageSenderName(for message: Message, at index: Int) -> Bool {
        guard channel.isGroupChat else { return false }
        let isNewDay = isNewDayToShowRelativeTimestamp(for: message, at: index)
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]

        if isNewDay {
            return !message.isSentByCurrentUser
        } else {
            return !message.isSentByCurrentUser && !message.isSentBySameUser(for: priorMessage)
        }
    }
    
    func addReaction(_ reaction: Reaction, to message: Message) {
        guard let currentUser else { return }
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        MessageService.addReaction(reaction: reaction, to: message, in: channel, from: currentUser) { [weak self] emojiCount in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.messages[index].reactions[reaction.emoji] = emojiCount
                self?.messages[index].userReactions[currentUser.uid] = reaction.emoji
            }
        }
    }
}
