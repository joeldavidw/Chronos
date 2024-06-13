import CoreTransferable
import Factory

struct ChronosTransferable: Transferable {    
    func getTokens() -> URL {
        let exportService = Container.shared.exportService()
        let chronosData = exportService.exportToUnencryptedJson()
        return chronosData
    }

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { chronos in
            chronos.getTokens()
        }
    }
}
