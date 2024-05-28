import UIKit
import FirebaseCore
import Firewrap
import FirebaseAuth
import GoogleSignIn
import SwiftBoost

public class FirewrapAuth {
    
    public static func configure(authDidChangedWork: (() -> Void)? = nil) {
        
        // Logs
        printConsole("Start configure. Current state isAuthed: " + (isAuthed ? "true" : "false"))
        if isAuthed {
            printConsole("User info: userID: \(userID ?? .empty), email: \(userEmail ?? "nil")")
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
        
        printConsole("Configure Complete")
    }
    
    public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handleEmailWay = handleSignInWithEmailURL(url) { error in
            shared.completionSignInViaEmail?(error)
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
    
    public static var providers: [FirewrapAuthProvider] {
        guard let providerData = Auth.auth().currentUser?.providerData else { return [] }
        var providers: [FirewrapAuthProvider] = []
        for providerMeta in providerData {
            if let provider = FirewrapAuthProvider.getByBaseURL(providerMeta.providerID) {
                providers.append(provider)
            }
        }
        return providers
    }
    
    /**
     Cached value if user authed
     */
    private static var isAuthedStored: Bool {
        get { UserDefaults.standard.bool(forKey: "firebase_wrapper_auth_is_authed_stored") }
        set { UserDefaults.standard.set(newValue, forKey: "firebase_wrapper_auth_is_authed_stored") }
    }
    
    // MARK: - Actions
    
    public static func signInWithApple(on controller: UIViewController, completion: ((SignInWithAppleData?, FirewrapAuthSignInError?) -> Void)?) {
        printConsole("Sign in with Apple...")
        guard let window = controller.view.window else {
            completion?(nil, .cantPresent)
            return
        }
        AppleAuthService.signIn(on: window) { data, appleError in
            if let appleError {
                printConsole("Sign in with Apple got error: \(appleError.localizedDescription)")
                completion?(nil, .failed)
                return
            }
            guard let data else {
                completion?(nil, .failed)
                return
            }
            let credential = OAuthProvider.appleCredential(
                withIDToken: data.identityToken,
                rawNonce: nil,
                fullName: data.name
            )
            Auth.auth().signIn(with: credential) { (authResult, firebaseError) in
                if let firebaseError {
                    printConsole("Sign in with Apple complete with Firebase error: \(firebaseError.localizedDescription)")
                    completion?(data, .failed)
                } else {
                    printConsole("Sign in with Apple complete")
                    completion?(data, nil)
                }
            }
        }
    }
    
    public static func signInWithGoogle(on controller: UIViewController, completion: ((FirewrapAuthSignInError?) -> Void)?) {
        printConsole("Sign in with Google...")
        GoogleAuthService.signIn(on: controller) { data, googleError in
            if let googleError {
                printConsole("Sign in with Google got error: \(googleError.localizedDescription)")
                completion?(googleError)
                return
            }
            guard let data else {
                completion?(.failed)
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: data.identityToken, accessToken: data.accessToken)
            Auth.auth().signIn(with: credential) { (authResult, firebaseError) in
                if let firebaseError {
                    printConsole("Sign in with Google complete with Firebase error: \(firebaseError.localizedDescription)")
                    completion?(.failed)
                } else {
                    printConsole("Sign in with Google complete")
                    completion?(.mustConfirmViaEmail) // Not exactly error, but shoud show user what need open email
                }
            }
        }
    }
    
    /**
     Firebase asking about Dynamic Links, but its will depicated. Observing how shoud change it
     */
    public static func signInWithEmail(email: String, handleURL: URL, completion: ((FirewrapAuthSignInError?) -> Void)?) {
        printConsole("Sign in with Email...")
        EmailAuthService.signIn(email: email, handleURL: handleURL) { emailError in
            if let emailError {
                printConsole("Sign in with Email complete with Firebase error: \(emailError.localizedDescription)")
                completion?(.failed)
            } else {
                printConsole("Sign in with Email complete")
                shared.completionSignInViaEmail = completion
                completion?(.mustConfirmViaEmail)
            }
        }
    }
    
    static func handleSignInWithEmailURL(_ url: URL, completion: ((FirewrapAuthSignInError?) -> Void)?) -> Bool {
        guard Auth.auth().isSignIn(withEmailLink: url.absoluteString) else {
            completion?(nil)
            return false
        }
        guard let processingEmail = EmailAuthService.processingEmail else {
            completion?(.failed)
            return false
        }
        Auth.auth().signIn(withEmail: processingEmail, link: url.absoluteString) { user, emailError in
            if let emailError {
                printConsole("Sign in with Email confirm action complete with Firebase error: \(emailError.localizedDescription)")
                completion?(.failed)
            } else {
                printConsole("Sign in with Email confirm action complete")
                completion?(nil)
            }
        }
        return true
    }
    
    public static func signOut(completion: @escaping (Error?)->Void) {
        printConsole("Sign out...")
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(error)
        }
        printConsole("Sign out complete")
    }
    
    public static func revokeSignInWithApple(authorizationCode: String) {
        printConsole("Revoke Sign in with Apple Token")
        Auth.auth().revokeToken(withAuthorizationCode: authorizationCode)
    }
    
    public static func delete(completion: @escaping (FirewrapDeleteProfileError?)->Void) {
        printConsole("Deleting Profile...")
        Auth.auth().currentUser?.delete(completion: { deleteError in
            let unwrapDeleteError: FirewrapDeleteProfileError? = {
                if let deleteError {
                    return FirewrapDeleteProfileError.get(by: deleteError) ?? .failed
                } else {
                    return nil
                }
            }()
            completion(unwrapDeleteError)
            printConsole("Delete Profile complete")
        })
    }
    
    public static func setDisplayName(_ name: String, completion: @escaping (Error?)->Void) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            completion(error)
        }
    }
    
    private static func printConsole(_ text: String) {
        debug("Firewrap, Auth: " + text)
    }
    
    // MARK: - Singltone
    
    private var observer: AuthStateDidChangeListenerHandle?
    private static let shared = FirewrapAuth()
    private var completionSignInViaEmail: ((FirewrapAuthSignInError?) -> Void)? = nil
    private init() {}
}
