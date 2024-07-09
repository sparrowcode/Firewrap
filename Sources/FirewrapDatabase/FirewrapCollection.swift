#if os(iOS)
import Foundation
import FirebaseFirestore

public class FirewrapCollection {
    
    public let path: String
    private var listener: ListenerRegistration?
    
    public init(_ path: String) {
        self.path = path
    }
    
    // MARK: - Getter
    
    func getDocuments(_ source: FirewrapSource = .default, completion: @escaping (([[String : Any]]?) -> Void)) {
        let db = Firestore.firestore()
        db.collection(path).getDocuments(source: source.firebaseValue) { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                completion(nil)
                return
            }
            completion(documents.map({ $0.data() }))
        }
    }
    
    func getDocument(_ source: FirewrapSource = .default, where field: String, equal: [Any], completion: @escaping (([[String : Any]]?) -> Void)) {
        let db = Firestore.firestore()
        db.collection(path).whereField(field, in: equal).getDocuments(source: source.firebaseValue) { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                completion(nil)
                return
            }
            completion(documents.map({ $0.data() }))
        }
    }
    
    // MARK: - Observer
    
    func observe(_ handler: @escaping ([[String : Any]]?) -> Void) {
        self.listener?.remove()
        let db = Firestore.firestore()
        self.listener = db.collection(path).addSnapshotListener { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                handler(nil)
                return
            }
            handler(documents.map({ $0.data() }))
        }
    }
}
#endif
