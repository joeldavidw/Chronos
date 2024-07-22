import Factory
import Foundation

enum StateEnum: String {
    case VAULT_ID

    case ICLOUD_BACKUP_ENABLED
    case BIOMETRICS_AUTH_ENABLED
    case ONBOARDING_COMPLETED

    case LAST_BIOMETRICS_AUTH_ATTEMPT

    case ICLOUD_SYNC_LAST_ATTEMPT

    case PASSWORD_REMINDER_ENABLED
    case NEXT_PASSWORD_REMINDER_TIMESTAMP

    case TAP_TO_REVEAL_ENABLED
}

public class StateService {
    private let defaults = UserDefaults.standard

    var masterKey: SecureBytes = .init(bytes: [])

    func setVaultId(vaultId: UUID) {
        defaults.setValue(vaultId.uuidString, forKey: StateEnum.VAULT_ID.rawValue)
    }

    func getVaultId() -> UUID? {
        guard let vaultIdStr = defaults.string(forKey: StateEnum.VAULT_ID.rawValue) else {
            return nil
        }

        return UUID(uuidString: vaultIdStr)
    }

    func resetAllStates() {
        defaults.setValue(nil, forKey: StateEnum.VAULT_ID.rawValue)

        defaults.setValue(false, forKey: StateEnum.ICLOUD_BACKUP_ENABLED.rawValue)
        defaults.setValue(false, forKey: StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue)
        defaults.setValue(false, forKey: StateEnum.ONBOARDING_COMPLETED.rawValue)

        defaults.setValue(Date().timeIntervalSince1970, forKey: StateEnum.LAST_BIOMETRICS_AUTH_ATTEMPT.rawValue)

        defaults.setValue(Date().timeIntervalSince1970, forKey: StateEnum.ICLOUD_SYNC_LAST_ATTEMPT.rawValue)

        defaults.setValue(4_102_444_800, forKey: StateEnum.NEXT_PASSWORD_REMINDER_TIMESTAMP.rawValue)
        defaults.setValue(true, forKey: StateEnum.PASSWORD_REMINDER_ENABLED.rawValue)

        defaults.setValue(false, forKey: StateEnum.TAP_TO_REVEAL_ENABLED.rawValue)

        masterKey.clear()
    }

    func clearMasterKey() {
        masterKey.clear()
    }
}
