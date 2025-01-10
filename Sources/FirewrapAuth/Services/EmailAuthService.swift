import UIKit
import Firebase
import FirebaseAuth

class EmailAuthService {
 
    static func signIn(email: String, handleURL: URL, completion: ((Error?) -> Void)?) {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = handleURL
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { emailError in
            if let emailError {
                FirewrapAuth.printConsole(emailError.localizedDescription)
            }
            completion?(emailError)
        }
    }
    
    // MARK: - Private
    
    static var processingEmail: String? {
        get { UserDefaults.standard.string(forKey: "firebase_wrapper_sign_in_process_email") }
        set { UserDefaults.standard.setValue(newValue, forKey: "firebase_wrapper_sign_in_process_email") }
    }
}
