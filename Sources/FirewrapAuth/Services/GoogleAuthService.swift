#if os(iOS) || os(macOS)
import UIKit
import Firebase
import GoogleSignIn

class GoogleAuthService {
 
    public static func signIn(on controller: UIViewController, completion: ((SignInWithGoogleData?, FirewrapAuthSignInError?) -> Void)?) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion?(nil, .unknow)
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { result, googleError in
            guard googleError == nil else {
                completion?(nil, .unknow)
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion?(nil, .unknow)
                return
            }
            let data = SignInWithGoogleData(identityToken: idToken, accessToken: user.accessToken.tokenString)
            completion?(data, nil)
        }
    }
}

public struct SignInWithGoogleData {
    
    public let identityToken: String
    public let accessToken: String
}
#endif
