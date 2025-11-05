import Firebase
import FirebaseStorage

enum FirebaseConstants {
    
    private static let databaseReference = Database.database().reference()
    
    static let UserReference = databaseReference.child("users")
}
