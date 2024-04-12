import UIKit
import FirebaseCore
import FirebaseWrapper
import FirebaseAuth
import GoogleSignIn
import SwiftBoost

public class FirebaseWrapperAuth {
    
    public static func configure(authDidChangedWork: (() -> Void)? = nil) {
        // Logs
        debug("FirebaseWrapper: Auth configure.")
        debug("FirebaseWrapper: Current state isAuthed: " + (isAuthed ? "true" : "false"))
        if isAuthed {
            debug("FirebaseWrapper: userID: \(userID ?? .empty), email: \(userEmail ?? "nil")")
        }
        // Observer Clean
        if let observer = shared.observer {
            Auth.auth().removeStateDidChangeListener(observer)
        }
        // Configure Observer
        shared.observer = Auth.auth().addStateDidChangeListener { auth, user in
            let newState = isAuthed
            let cachedState = isAuthedStored
            if (newState != cachedState) {
                authDidChangedWork?()
                isAuthedStored = newState
            }
        }
    }
    
    public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handleEmailWay = handleSignInWithEmailURL(url) { error in
            // Process auth after handle email
        }
        if handleEmailWay {
            return true
        } else {
            return GIDSignIn.sharedInstance.handle(url)
        }
    }
    
    // MARK: - Data
    
    public static var isAuthed: Bool { userID != nil }
    public static var userID: String? { Auth.auth().currentUser?.uid }
    public static var userName: String? { Auth.auth().currentUser?.displayName }
    public static var userEmail: String? { Auth.auth().currentUser?.email }
    
    public static var providers: [FirebaseAuthProvider] {
        guard let providerData = Auth.auth().currentUser?.providerData else { return [] }
        var providers: [FirebaseAuthProvider] = []
        for providerMeta in providerData {
            if let provider = FirebaseAuthProvider.getByBaseURL(providerMeta.providerID) {
                providers.append(provider)
            }
        }
        return providers
    }
    
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
            if let appleError {
                debug("FirebaseWrapper: Sign in with Apple error: \(appleError.localizedDescription)")
                return
            }
            guard let data else {
                completion?(nil, AuthError.cantMakeData)
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
    
    public static func signInWithGoogle(on controller: UIViewController, completion: ((SignInWithAppleData?, Error?) -> Void)?) {
        debug("FirebaseWrapper: Auth start sign in with Google")
        GoogleAuthService.signIn(on: controller) { data, googleError in
            if let googleError {
                debug("FirebaseWrapper: Sign in with Google error: \(googleError.localizedDescription)")
                return
            }
            guard let data else {
                completion?(nil, AuthError.cantMakeData)
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: data.identityToken, accessToken: data.accessToken)
            Auth.auth().signIn(with: credential) { (authResult, firebaseError) in
                completion?(nil, firebaseError)
            }
        }
    }
    
    public static func signInWithEmail(email: String, handleURL: URL, completion: ((Error?) -> Void)?) {
        debug("FirebaseWrapper: Auth start sign in with Email")
        EmailAuthService.signIn(email: email, handleURL: handleURL) { emailError in
            if let emailError {
                debug("FirebaseWrapper: Sign in with Email error: \(emailError.localizedDescription)")
            }
            completion?(emailError)
        }
    }
    
    static func handleSignInWithEmailURL(_ url: URL, completion: ((Error?) -> Void)?) -> Bool {
        guard Auth.auth().isSignIn(withEmailLink: url.absoluteString) else {
            completion?(AuthError.cantMakeData)
            return false
        }
        guard let processingEmail = EmailAuthService.processingEmail else {
            completion?(AuthError.cantMakeData)
            return false
        }
        Auth.auth().signIn(withEmail: processingEmail, link: url.absoluteString) { user, emailError in
            completion?(emailError)
        }
        return true
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
        
        // Basic Delete Account
        let deleteAccountAction = {
            do {
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
        
        let providers = providers
        if providers.isEmpty {
            #warning("del account error make enum")
            completion(AuthError.cantMakeData)
            return
        }
        
        let provider = providers.first!
        
        // Check which provider for reauth https://firebase.google.com/docs/auth/ios/manage-users#delete_a_user
        // Check if sign in with apple for revoke token, maybe first do it and later check others
        // after auth deelte account
        // FIRAuthErrorCodeCredentialTooOld error when delete call reauth only when happen this error
        
        /*
        guard let providers = Auth.auth().currentUser?.providerData, !providers.isEmpty else {
            completion(AuthError.cantMakeData)
            return
        }
        
        
        
        // Basic Delete Account
        let deleteAccountAction = {
            do {
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
        
        // Check if contains Apple sign in for revoke token first
        if providers.contains(where: { $0.providerID == "apple.com" }) {
            signInWithApple(on: controller) { authData, appleError in
                
                guard let code = authData?.authorizationCode else {
                    completion(appleError)
                    return
                }
                
                Task {
                    // Revoke Token First
                    do {
                        try await Auth.auth().revokeToken(withAuthorizationCode: code)
                    } catch {
                        DispatchQueue.main.async {
                            completion(error)
                            return
                        }
                    }
                    
                    // Basic Delete Account
                    await deleteAccountAction()
                }
            }
        } else {
            Task {
                // Basic Delete Account
                await deleteAccountAction()
            }
        }*/
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
