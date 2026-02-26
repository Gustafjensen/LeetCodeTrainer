import SwiftUI

enum AdaptiveLayout {
    static func gridColumns(
        for sizeClass: UserInterfaceSizeClass?,
        compactCount: Int = 2,
        regularCount: Int = 3
    ) -> [GridItem] {
        let count = sizeClass == .regular ? regularCount : compactCount
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
    }

    static func editorMaxHeight(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 700 : 500
    }

    static func editorMinHeight(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 250 : 150
    }
}
