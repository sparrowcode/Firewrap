import UIKit
import AuthenticationServices

class AppleAuthService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    static func signIn(on window: UIWindow, completion: ((SignInWithAppleData?, Error?) -> Void)?) {
        shared.completion = completion
        shared.window = window
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = shared
        authorizationController.presentationContextProvider = shared
        authorizationController.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = appleCredential.identityToken,
            let identityTokenString = String(data: identityToken, encoding: .utf8),
            let authorizationCode = appleCredential.authorizationCode,
            let authorizationCodeString = String(data: authorizationCode, encoding: .utf8)
        else {
            // todo parse
            completion?(nil, FirewrapAuthSignInError.failed)
            return
        }
        
        let data = SignInWithAppleData(
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString,
            name: appleCredential.fullName,
            email: appleCredential.email
        )
        completion?(data, nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let error = error as? ASAuthorizationError {
            switch error.code {
            case .canceled:
                // Cancel sign in not error
                completion?(nil, nil)
                return
            default:
                completion?(nil, error)
            }
        }
        
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.window else { fatalError("Can't get root window") }
        return window
    }
    
    // MARK: - Singltone
    
    private weak var window: UIWindow?
    private var completion: ((SignInWithAppleData?, Error?) -> Void)?
    private static let shared = AppleAuthService()
    private override init() {}
}

public struct SignInWithAppleData {
    
    public let identityToken: String
    public let authorizationCode: String
    public let name: PersonNameComponents?
    public let email: String?
}
