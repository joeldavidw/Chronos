import XCTest

final class LocalVaultTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        let getStartedBtn = app.buttons["GetStartedBtn"]
        getStartedBtn.tap()

        let localVaultBtn = app.buttons["LocalVaultBtn"]
        localVaultBtn.tap()

        let localVaultConfirmationBtn = app.buttons["LocalVaultConfirmationBtn"]
        localVaultConfirmationBtn.tap()

        let passwordSecureField = app.secureTextFields["PasswordSecureField"]
        passwordSecureField.typeText("hellohello")
        passwordSecureField.typeText("\n")

        let verifyPasswordSecureField = app.secureTextFields["VerifyPasswordSecureField"]
        verifyPasswordSecureField.typeText("hellohello")
        verifyPasswordSecureField.typeText("\n")

        XCTAssertTrue(app.staticTexts["Biometrics"].waitForExistence(timeout: 5))

        let noBiometricsBtn = app.buttons["NoBiometricsBtn"]
        noBiometricsBtn.tap()
        
        XCTAssertTrue(app.staticTexts["Tokens"].waitForExistence(timeout: 2))
//        app.tabBars.element.buttons["Settings"].tap()
        
        
        // Create Token
        app.buttons["AddTokenBtn"].tap()
        
        app.buttons["ManualAddTokenBtn"].tap()
        
        let issuerField = app.textFields["AddTokenForm_Issuer"]
        XCTAssertTrue(issuerField.waitForExistence(timeout: 2))
        issuerField.tap()
        issuerField.typeText("Test")
            
        let accountField = app.textFields["AddTokenForm_Account"]
        accountField.tap()
        accountField.typeText("Test Account")
        
        let secretField = app.secureTextFields["AddTokenForm_Secret"]
        secretField.tap()
        secretField.typeText("ff")
                
        app.navigationBars.element.buttons["Save"].tap()
        
        // Check if exists
        
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    //    func testLaunchPerformance() throws {
    //        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
    //            // This measures how long it takes to launch your application.
    //            measure(metrics: [XCTApplicationLaunchMetric()]) {
    //                XCUIApplication().launch()
    //            }
    //        }
    //    }
}
