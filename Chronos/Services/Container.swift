import Factory

extension Container {
    var secureEnclaveService: Factory<SecureEnclaveService> {
        Factory(self) { SecureEnclaveService() }
    }

    var swiftDataService: Factory<SwiftDataService> {
        Factory(self) { SwiftDataService() }
            .singleton
    }

    var cryptoService: Factory<CryptoService> {
        Factory(self) { CryptoService() }
    }

    var otpService: Factory<OTPService> {
        Factory(self) { OTPService() }
    }

    var stateService: Factory<StateService> {
        Factory(self) { StateService() }
            .singleton
    }
}
