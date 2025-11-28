import Firebase
import FirebaseStorage
import FirebaseDatabase

enum FirebaseConstants {
    
    private static let databaseReference = Database.database().reference()
    
    static let UserReference = databaseReference.child("users")
    static let ChannelsReference = databaseReference.child("channels")
    static let MessagesReference = databaseReference.child("channel-messages")
    static let UserChannelsReference = databaseReference.child("user-channels")
    static let UserDirectChannels = databaseReference.child("user-direct-channels")
    
    static let StorageRefenrence = Storage.storage().reference()
}
