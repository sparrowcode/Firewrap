import Foundation
import Firewrap
import FirebaseRemoteConfig
import SwiftBoost

class FirewrapRemoteConfig {
    
    public static func configure(
        defaults: [String : NSObject]? = nil,
        updatedHandler: (() -> Void)? = nil
    ) {
        printConsole("RemoteConfig configure")
        shared.updatedHandler = updatedHandler
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        shared.remoteConfig.configSettings = settings
        shared.remoteConfig.setDefaults(defaults ?? [:])
        
        printConsole("RemoteConfig fetchAndActivate")
        shared.remoteConfig.fetch { updateStatus, getError in
            switch updateStatus {
            case .success:
                activateNewConfig()
            case .failure, .noFetchYet, .throttled:
                printConsole("RemoteConfig initial get with error, " + (getError?.localizedDescription ?? .empty))
                break
            @unknown default:
                break
            }
        }
        
        shared.remoteConfig.addOnConfigUpdateListener { configUpdate, listnerError in
            guard listnerError == nil else {
                printConsole("RemoteConfig got update in listner with error, " + (listnerError?.localizedDescription ?? .empty))
                return
            }
            printConsole("RemoteConfig activate after got new in listner")
            activateNewConfig()
        }
    }
    
    private static func activateNewConfig() {
        shared.remoteConfig.activate { changed, activateError in
            guard activateError == nil else {
                printConsole("RemoteConfig can't activate after got new in listner, " + (activateError?.localizedDescription ?? .empty))
                return
            }
            
            shared.updatedHandler?()
            NotificationCenter.default.post(name: .firebaseWrapperRemoteConfigUpdated)
        }
    }
    
    public static func getBool(key: String) -> Bool {
        shared.remoteConfig.configValue(forKey: key).boolValue
    }
    
    private static func printConsole(_ text: String) {
        debug("Firewrap, Auth: " + text)
    }
    
    private var updatedHandler: (() -> Void)? = nil
    private static let shared = FirewrapRemoteConfig()
    private let remoteConfig = FirebaseRemoteConfig.RemoteConfig.remoteConfig()
    private init() {}
}

extension Notification.Name {
    
    public static var firebaseWrapperRemoteConfigUpdated = Notification.Name("FirebaseWrapperRemoteConfigUpdated")
}
