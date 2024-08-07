import Foundation
import FirebaseAuth

public enum FirewrapDeleteProfileError: Error {
    
    case requiredLogin
    case faildSignInConfirm
    case failed
    
    public static func get(by error: Error) -> FirewrapDeleteProfileError? {
        let error = error as NSError
        guard error.domain == AuthErrorDomain else{
            return nil
        }
        #warning("here migrated to firebase 11 so need test if code unwrap corectly")
        let authErrorCode = AuthErrorCode.init(rawValue: error.code)
        switch authErrorCode {
        case .requiresRecentLogin:
            return .requiredLogin
        default:
            return .failed
        }
    }
}
