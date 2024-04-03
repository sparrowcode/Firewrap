import Foundation

public enum AuthError: LocalizedError {
  
    case cantPresent
    case cantMakeData
    
    public var errorDescription: String? {
        switch self {
        case .cantPresent: return "can't present"
        case .cantMakeData: return "can't make data"
        }
    }
}
