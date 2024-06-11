import Factory
import Foundation
import Logging
import Valet

enum KeyChainEnum: String {
    case BIOMETRICS_MASTERKEY
}

public class SecureEnclaveService {
    private let logger = Logger(label: "SecureEnclaveService")
    private let chronosSecureValet = SecureEnclaveValet.valet(with: Identifier(nonEmpty: "ChronosSecureValet")!, accessControl: .userPresence)

    private let stateService = Container.shared.stateService()

    func reset() {
        try? chronosSecureValet.removeAllObjects()
    }

    func saveMasterKey() {
        do {
            try chronosSecureValet.setObject(Data(stateService.masterKey), forKey: KeyChainEnum.BIOMETRICS_MASTERKEY.rawValue)
            logger.info("Successfully saved master key in secure encalve.")
        } catch {
            logger.error("Error saving master key in secure encalve.")
        }
    }

    func getMasterKey() -> [UInt8]? {
        return try? Array(chronosSecureValet.object(forKey: KeyChainEnum.BIOMETRICS_MASTERKEY.rawValue, withPrompt: "Unlock Chronos"))
    }

    func deleteMasterKey() {
        do {
            try chronosSecureValet.removeObject(forKey: KeyChainEnum.BIOMETRICS_MASTERKEY.rawValue)
            logger.info("Successfully deleted master key in secure encalve.")
        } catch {
            logger.error("Error deleting master key in secure encalve.")
        }
    }
}
