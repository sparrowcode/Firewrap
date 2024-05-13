import Foundation
import FirebaseFirestore

public enum FWFirestoreSource {
    
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

public class FirewrapDocument {
    
    public let path: String
    
    public init(_ path: String) {
        self.path = path
    }
    
    public func set(_ data: [String : Any], merge: Bool) {
        let db = Firestore.firestore()
        db.document(path).setData(data, merge: merge)
    }
    
    public func get(_ source: FWFirestoreSource = .default, completion: @escaping (([String : Any]?) -> Void)) {
        let db = Firestore.firestore()
        db.document(path).getDocument(source: source.firebaseValue) { document, error in
            if error == nil {
                completion(nil)
                return
            }
            completion(document?.data())
        }
    }
    
    public func delete(_ completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.document(path).delete { error in
            completion(error == nil)
        }
    }
    
    public func observe(_ handler: () -> Void) {
        
    }
}
