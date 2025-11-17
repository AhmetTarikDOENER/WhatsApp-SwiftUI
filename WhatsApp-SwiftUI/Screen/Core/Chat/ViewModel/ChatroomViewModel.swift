import Combine

final class ChatroomViewModel: ObservableObject {
    
    @Published var textMessage = ""
    
    func sendMessage() {
        print("textMessage: \(textMessage)")
    }
}
