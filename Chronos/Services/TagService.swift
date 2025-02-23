import Factory
import Foundation
import Logging
import SwiftData

public class TagService {
    private let logger = Logger(label: "TagService")

    private let stateService = Container.shared.stateService()

    func validateTag(_ tag: String) -> Bool {
        let tempTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let isNotEmpty = !tempTag.isEmpty
        let isUnique = !stateService.tags.contains { $0.caseInsensitiveCompare(tempTag) == .orderedSame }
        let hasValidCharacters = tempTag.range(of: "^[\\p{L}0-9_\\s\\p{P}\\p{S}]+$", options: .regularExpression) != nil
        let hasValidLength = (1 ... 20).contains(tempTag.count)

        return isNotEmpty && isUnique && hasValidCharacters && hasValidLength
    }
}
