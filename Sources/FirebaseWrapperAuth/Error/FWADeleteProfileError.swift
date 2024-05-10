import Foundation
import FirebaseAuth

public enum FWADeleteProfileError: Error {
    
    case requiredLogin
    case faildSignInConfirm
    case failed
    
    public static func get(by error: Error) -> FWADeleteProfileError? {
        let error = error as NSError
        guard error.domain == AuthErrorDomain else{
            return nil
        }
        let code = AuthErrorCode.init(_nsError: error)
        switch code.code {
        case .requiresRecentLogin:
            return .requiredLogin
        default:
            return .failed
        }
    }
}
