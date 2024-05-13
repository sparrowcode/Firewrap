import Foundation
import FirebaseCore
import SwiftBoost

open class Firewrap {
    
    public static func configure(with options: FirebaseOptions) {
        FirebaseApp.configure(options: options)
    }
}
