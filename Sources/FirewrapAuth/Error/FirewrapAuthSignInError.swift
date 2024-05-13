import Foundation
import FirebaseAuth

public enum FirewrapAuthSignInError: Error {
    
    case cantPresent
    case mustConfirmViaEmail
    case failed
}
