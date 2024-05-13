import Foundation
import FirebaseAuth

public enum FWAuthSignInError: Error {
    
    case cantPresent
    case mustConfirmViaEmail
    case failed
}
