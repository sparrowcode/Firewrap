#if canImport(SwiftUI)
import SwiftUI
import AuthenticationServices

@available(iOS 14.0, *)
public struct WrapperSignInWithAppleButton: View {
    
    private let completion: ((SignInWithAppleData?, FirewrapAuthSignInError?) -> Void)?
    
    public init(completion: ((SignInWithAppleData?, FirewrapAuthSignInError?) -> Void)? = nil) {
        self.completion = completion
    }
    
    public var body: some View {
        SignInWithAppleButton { request in
            
        } onCompletion: { result in
            switch result {
            case .success(let authorisation):
                AppleAuthService.parse(authorisation) { data, error in
                    if let data {
                        FirewrapAuth.signInWithApple(with: data, completion: completion)
                    } else {
                        self.completion?(nil, error ?? .failed)
                    }
                }
            case .failure(_):
                self.completion?(nil, .failed)
            }
        }
    }
}
#endif
