import Foundation
import FirebaseWrapper
import FirebaseRemoteConfig
// import SwiftBoost

extension FirebaseWrapper {
    
    public class RemoteConfig {
        
        public static func configure(
            defaults: [String : NSObject]? = nil,
            updatedHandler: (() -> Void)? = nil
        ) {
            // debug("FirebaseWrapper: RemoteConfig configure")
            shared.updatedHandler = updatedHandler
            
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 0
            shared.remoteConfig.configSettings = settings
            shared.remoteConfig.setDefaults(defaults ?? [:])
            
            // debug("FirebaseWrapper: RemoteConfig fetchAndActivate")
            shared.remoteConfig.fetch { updateStatus, getError in
                switch updateStatus {
                case .success:
                    activateNewConfig()
                case .failure, .noFetchYet, .throttled:
                    //error("FirebaseWrapper: RemoteConfig initial get with error, " + (getError?.localizedDescription ?? .empty))
                    break
                @unknown default:
                    break
                }
            }
            
            shared.remoteConfig.addOnConfigUpdateListener { configUpdate, listnerError in
                guard listnerError == nil else {
                    //error("FirebaseWrapper: RemoteConfig got update in listner with error, " + (listnerError?.localizedDescription ?? .empty))
                    return
                }
                // debug("FirebaseWrapper: RemoteConfig activate after got new in listner")
                activateNewConfig()
            }
        }
        
        private static func activateNewConfig() {
            shared.remoteConfig.activate { changed, activateError in
                guard activateError == nil else {
                    // error("FirebaseWrapper: RemoteConfig can't activate after got new in listner, " + (activateError?.localizedDescription ?? .empty))
                    return
                }
                
                shared.updatedHandler?()
                // NotificationCenter.default.post(name: .firebaseWrapperRemoteConfigUpdated)
            }
        }
        
        public static func getBool(key: String) -> Bool {
            shared.remoteConfig.configValue(forKey: key).boolValue
        }
        
        private var updatedHandler: (() -> Void)? = nil
        private static let shared = RemoteConfig()
        private let remoteConfig = FirebaseRemoteConfig.RemoteConfig.remoteConfig()
        private init() {}
    }
}

extension Notification.Name {
    
    public static var firebaseWrapperRemoteConfigUpdated = Notification.Name("FirebaseWrapperRemoteConfigUpdated")
}
