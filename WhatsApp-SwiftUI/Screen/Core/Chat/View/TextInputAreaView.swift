import SwiftUI

struct TextInputAreaView: View {
    
    //  MARK: - Properties
    @Binding var textMessage: String
    @Binding var isRecording: Bool
    @Binding var elapsedTime: TimeInterval
    @State private var isPulsing = false
    let actionHandler: (_ action: UserAction) -> Void
    
    private var disableSendButton: Bool { textMessage.isEmptyOrWhitespace || isRecording }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            imagePickerButton()
                .padding(3)
            audioRecorderButton()
            
            if isRecording {
                audioRecordingIndicatorView()
            } else {
                messageTextField()
            }
            
            sendMessageButton()
                .disabled(disableSendButton)
                .grayscale(disableSendButton ? 0.8 : 0)
        }
        .padding(.bottom)
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .background(.whatsAppWhite)
        .animation(.spring, value: isRecording)
        .onChange(of: isRecording) { oldValue, isRecording in
            if isRecording {
                withAnimation(.easeInOut(duration: 1.35).repeatForever()) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
    
    //  MARK: - Private
    private func imagePickerButton() -> some View {
        Button {
            actionHandler(.presentPhotoPicker)
        } label: {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 20))
        }
    }
    
    private func audioRecorderButton() -> some View {
        Button {
            actionHandler(.recordAudio)
        } label: {
            Image(systemName: isRecording ? "square.fill" : "mic.fill")
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(6)
                .background(isRecording ? .red : .blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
    }
    
    private func messageTextField() -> some View {
        TextField("", text: $textMessage, axis: .vertical)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(textViewBorder())
    }
    
    private func textViewBorder() -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(Color(.systemGray5), lineWidth: 1)
    }
    
    private func sendMessageButton() -> some View {
        Button {
            actionHandler(.sendMessage)
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 20))
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(6)
                .background(.blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
    }
    
    private func audioRecordingIndicatorView() -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .scaleEffect(isPulsing ? 1.75 : 1.0)
            
            Text("Recording Audio")
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            
            Text(elapsedTime.formatElapsedTime)
                .font(.callout)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .clipShape(Capsule())
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.blue.opacity(0.1))
        )
        .overlay { textViewBorder() }
    }
}

//  MARK: - TextInputAreaView+UserAction
extension TextInputAreaView {
    enum UserAction {
        case presentPhotoPicker
        case sendMessage
        case recordAudio
    }
}

#Preview {
    TextInputAreaView(
        textMessage: .constant(""),
        isRecording: .constant(false),
        elapsedTime: .constant(0)
    ) { action in
        
    }
}
