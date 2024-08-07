#if os(iOS)
import Foundation
import FirebaseFirestore

public enum FirewrapSource {
    
    case `default`
    case server
    case cache
    
    var firebaseValue: FirestoreSource {
        switch self {
        case .default: return .default
        case .server: return .server
        case .cache: return .cache
        }
    }
}
#endif
