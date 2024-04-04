import UIKit
import FirebaseCore
import GoogleSignIn

class GoogleAuthService {
 
    public static func signInWithGoogle(on controller: UIViewController, completion: ((SignInWithGoogleData?, Error?) -> Void)?) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion?(nil, AuthError.cantMakeData)
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { result, googleError in
            guard googleError == nil else {
                completion?(nil, googleError)
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion?(nil, AuthError.cantMakeData)
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
