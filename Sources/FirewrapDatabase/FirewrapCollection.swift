#if os(iOS)
import Foundation
import FirebaseFirestore

public class FirewrapCollection {
    
    public let path: String
    private var listener: ListenerRegistration?
    
    public init(_ path: String) {
        self.path = path
    }
    
    public func document() -> FirewrapDocument {
        let db = Firestore.firestore()
        let newDocument = db.collection(path).document()
        return FirewrapDocument(newDocument.path)
    }
    
    public func document(_ path: String) -> FirewrapDocument {
        return FirewrapDocument(self.path + "/" + path)
    }
    
    // MARK: - Getter
    
    public func getDocuments(_ source: FirewrapSource = .default, completion: @escaping ([[String : Any]]?) -> Void) {
        let db = Firestore.firestore()
        db.collection(path).getDocuments(source: source.firebaseValue) { snapshot, error in
            
            guard error == nil, let documents = snapshot?.documents else {
                completion(nil)
                return
            }
            
            let response = documents.map { $0.data() }
            completion(response)
        }
    }
    
    public func getDocuments<T: Decodable>(as type: T.Type, source: FirewrapSource = .default, completion: @escaping ([T]?, Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection(path).getDocuments(source: source.firebaseValue) { (snapshot, error) in
            
            guard error == nil, let snapshot else {
                completion(nil, error)
                return
            }
            
            let models = Self.decode(as: T.self, from: snapshot)
            completion(models, nil)
        }
    }
    
    public func getDocument(_ source: FirewrapSource = .default, where field: String, equal: [Any], completion: @escaping (([[String : Any]]?) -> Void)) {
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
    
    public func observe<T: Decodable>(as type: T.Type, handler: @escaping ([T]?) -> Void) {
        self.listener?.remove()
        let db = Firestore.firestore()
        self.listener = db.collection(path).addSnapshotListener { snapshot, error in
            
            guard error == nil, let snapshot else {
                handler(nil)
                return
            }

            handler(Self.decode(as: T.self, from: snapshot))
        }
    }
    
    public func observe(_ handler: @escaping ([[String : Any]]?) -> Void) {
        self.listener?.remove()
        let db = Firestore.firestore()
        self.listener = db.collection(path).addSnapshotListener { snapshot, error in
            
            guard error == nil, let documents = snapshot?.documents else {
                handler(nil)
                return
            }
            
            let response = documents.map { $0.data() }
            handler(response)
        }
    }
    
    public func removeObserver() {
        self.listener?.remove()
    }
    
    // MARK: - Private
    
    private static func decode<T: Decodable>(as type: T.Type, from snapshot: QuerySnapshot) -> [T]? {
        var models: [T] = []
        for document in snapshot.documents {
            do {
                let model = try document.data(as: T.self)
                models.append(model)
            } catch {
                break
            }
        }
        return models
    }
}
#endif
