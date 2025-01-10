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
    
    public var lastPath: String {
        path.split(separator: "/").last?.base ?? path
    }
    
    // MARK: - Getter
    
    public func get(_ source: FirewrapSource = .default, completion: @escaping (([String : Any]?, Error?) -> Void)) {
        let db = Firestore.firestore()
        db.document(path).getDocument(source: source.firebaseValue) { document, error in
            if let error {
                completion(nil, error)
                return
            }
            completion(document?.data(), nil)
        }
    }
    
    public func get<T: Decodable>(as type: T, source: FirewrapSource = .default, completion: @escaping ((T?, Error?) -> Void)) {
        let db = Firestore.firestore()
        db.document(path).getDocument(as: T.self, source: source.firebaseValue) { result in
            switch result {
                case .success(let model):
                    completion(model, nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    // MARK: - Setter
    
    public func set(_ data: [String : Any], merge: Bool, completion: @escaping ((Bool, Error?) -> Void)) {
        let db = Firestore.firestore()
        db.document(path).setData(data, merge: merge) { error in
            if let error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    public func set<T: Encodable>(_ model: T, merge: Bool, completion: @escaping ((Bool, Error?) -> Void)) {
        let db = Firestore.firestore()
        do {
            try db.document(path).setData(from: model, merge: merge) { error in
                if let error {
                    completion(false, error)
                    return
                }
                completion(true, nil)
            }
        } catch {
            completion(false, error)
        }
    }
    
    public func delete(_ completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        db.document(path).delete { error in
            if let error {
                completion(false, error)
                return
            }
            completion(true, error)
        }
    }
    
    // MARK: - Observer
    
    public func observe(_ handler: @escaping (([String : Any]?) -> Void)) {
        
        removeObserver()
    
        let db = Firestore.firestore()
        self.listener = db.document(path).addSnapshotListener { document, error in
            if let document, let data = document.data() {
                handler(data)
            } else {
                handler(nil)
            }
        }
    }
    
    public func observe<T: Decodable>(as type: T.Type, handler: @escaping ((T?) -> Void)) {
        
        removeObserver()
    
        let db = Firestore.firestore()
        self.listener = db.document(path).addSnapshotListener { document, error in
            if let document, let data = try? document.data(as: T.self) {
                handler(data)
            } else {
                handler(nil)
            }
        }
    }
    
    public func removeObserver() {
        if let listener = self.listener {
            listener.remove()
        }
    }
}
#endif
