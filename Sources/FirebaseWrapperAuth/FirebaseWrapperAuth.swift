import Foundation
import UIKit
import FirebaseWrapper
import FirebaseAuth
import SwiftBoost

public class FirebaseWrapperAuth {
    
    public static func configure(authDidChangedWork: (() -> Void)? = nil) {
        debug("FirebaseWrapper: Auth configure")
        if let observer = shared.observer {
            Auth.auth().removeStateDidChangeListener(observer)
        }
        shared.observer = Auth.auth().addStateDidChangeListener { auth, user in
            let newState = isAuthed
            let cachedState = isAuthedStored
            if (newState != cachedState) {
                authDidChangedWork?()
                isAuthedStored = newState
            }
        }
    }
    
    // MARK: - Data
    
    public static var isAuthed: Bool { userID != nil }
    public static var userID: String? { Auth.auth().currentUser?.uid }
    public static var userName: String? { Auth.auth().currentUser?.displayName }
    public static var userEmail: String? { Auth.auth().currentUser?.email }
    
    private static var isAuthedStored: Bool {
        get { UserDefaults.standard.bool(forKey: "firebase_wrapper_auth_is_authed_stored") }
        set { UserDefaults.standard.set(newValue, forKey: "firebase_wrapper_auth_is_authed_stored") }
    }
    
    // MARK: - Actions
    
    public static func signInWithApple(on controller: UIViewController, completion: ((SignInWithAppleData?, Error?) -> Void)?) {
        debug("FirebaseWrapper: Auth start sign in with Apple")
        guard let window = controller.view.window else {
            completion?(nil, AuthError.cantPresent)
            return
        }
        AppleAuthService.signIn(on: window) { data, appleError in
            guard let data else {
                completion?(nil, appleError)
                return
            }
            let credential = OAuthProvider.appleCredential(
                withIDToken: data.identityToken,
                rawNonce: nil,
                fullName: data.name
            )
            Auth.auth().signIn(with: credential) { (authResult, firebaseError) in
                completion?(data, firebaseError)
            }
        }
    }
    
    public static func signOut(completion: @escaping (Error?)->Void) {
        debug("FirebaseWrapper: Auth start sign out")
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public static func delete(on controller: UIViewController, completion: @escaping (Error?)->Void) {
        debug("FirebaseWrapper: Auth start delete")
        signInWithApple(on: controller) { authData, error in
            guard let code = authData?.authorizationCode else {
                completion(error)
                return
            }
            Task {
                do {
                    try await Auth.auth().revokeToken(withAuthorizationCode: code)
                    try await Auth.auth().currentUser?.delete()
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            }
        }
    }
    
    public static func setDisplayName(_ name: String, completion: @escaping (Error?)->Void) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            completion(error)
        }
    }
    
    // MARK: - Singltone
    
    private var observer: AuthStateDidChangeListenerHandle?
    private static let shared = FirebaseWrapperAuth()
    private init() {}
}
