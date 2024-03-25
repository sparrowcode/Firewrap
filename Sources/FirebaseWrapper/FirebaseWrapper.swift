import Foundation
import FirebaseCore
import SwiftBoost

open class FirebaseWrapper {
    
    public static func configure() {
        Logger.configure(levels: Logger.Level.allCases, fileNameMode: .show)
        FirebaseApp.configure()
    }
}
