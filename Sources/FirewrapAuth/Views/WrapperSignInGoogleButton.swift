#if canImport(SwiftUI)
import SwiftUI
import GoogleSignIn

public struct WrapperSignInGoogleButton: UIViewRepresentable {
    
    public init() {}
    
    public func makeUIView(context: Context) -> GIDSignInButton {
        return GIDSignInButton()
    }

    public func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
}
#endif
