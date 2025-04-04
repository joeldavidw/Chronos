import Factory

extension Container {
    var secureEnclaveService: Factory<SecureEnclaveService> {
        Factory(self) { SecureEnclaveService() }
    }

    var swiftDataService: Factory<SwiftDataService> {
        Factory(self) { SwiftDataService() }
            .singleton
    }

    var vaultService: Factory<VaultService> {
        Factory(self) { VaultService() }
    }

    var cryptoService: Factory<CryptoService> {
        Factory(self) { CryptoService() }
    }

    var stateService: Factory<StateService> {
        Factory(self) { StateService() }
            .singleton
    }

    var exportService: Factory<ExportService> {
        Factory(self) { ExportService() }
    }

    var importService: Factory<ImportService> {
        Factory(self) { ImportService() }
    }

    var tagService: Factory<TagService> {
        Factory(self) { TagService() }
    }
}
