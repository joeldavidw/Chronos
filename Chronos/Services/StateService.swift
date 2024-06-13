import Factory
import Foundation

enum StateEnum: String {
    case VAULT
    
    case ICLOUD_BACKUP_ENABLED
    case BIOMETRICS_AUTH_ENABLED
    case ONBOARDING_COMPLETED

    case LAST_BIOMETRICS_AUTH_ATTEMPT
}

public class StateService {
    private let defaults = UserDefaults.standard

    var masterKey: SecureBytes = .init(bytes: [])
    var vault: Vault?

    func resetAllStates() {
        defaults.setValue(false, forKey: StateEnum.ICLOUD_BACKUP_ENABLED.rawValue)
        defaults.setValue(false, forKey: StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue)
        defaults.setValue(false, forKey: StateEnum.ONBOARDING_COMPLETED.rawValue)

        defaults.setValue(0, forKey: StateEnum.LAST_BIOMETRICS_AUTH_ATTEMPT.rawValue)

        masterKey.clear()
    }

    func clearMasterKey() {
        masterKey.clear()
    }
}
