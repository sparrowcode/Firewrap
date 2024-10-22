#if os(iOS)
import Foundation
import FirebaseFirestore

// Using for wrap default firebase value
public typealias FirewrapFieldNil = NSNull

public class FirewrapDocument {
    
    public let path: String
    private var listener: ListenerRegistration?
    
    public init(_ path: String) {
        self.path = path
    }
    
    // MARK: - Getter
    
#warning("add error or state")
    public func get(_ source: FirewrapSource = .default, completion: @escaping (([String : Any]?) -> Void)) {
        let db = Firestore.firestore()
        db.document(path).getDocument(source: source.firebaseValue) { document, error in
            guard error == nil else {
                completion(nil)
                return
            }
            completion(document?.data())
        }
    }
    
    // MARK: - Setter
    
    #warning("add error or state")
    public func set(_ data: [String : Any], merge: Bool, completion: @escaping (() -> Void)) {
        let db = Firestore.firestore()
        db.document(path).setData(data, merge: merge) { error in
            guard error == nil else {
                completion()
                return
            }
            completion()
        }
    }
    
    public func delete(_ completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.document(path).delete { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Observer
    
    public func observe(_ handler: @escaping (([String : Any]?) -> Void)) {
        self.listener?.remove()
        let db = Firestore.firestore()
        self.listener = db.document(path).addSnapshotListener { document, error in
            if let document, let data = document.data() {
                handler(data)
            } else {
                handler(nil)
            }
        }
    }
    
    public func removeObserver() {
        self.listener?.remove()
    }
}
#endif
