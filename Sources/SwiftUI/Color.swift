import SwiftUI

extension Color {
    // MARK: - hex

    public init(
        hex: UInt64,
        opacity: Double = 1
    ) {
        let r = (hex & 0xff0000) >> 16
        let g = (hex & 0xff00) >> 8
        let b = hex & 0xff

        self.init(
            red: Double(r) / 0xff,
            green: Double(g) / 0xff,
            blue: Double(b) / 0xff,
            opacity: opacity
        )
    }

    public init(
        hexString: String,
        opacity: Double = 1
    ) {
        let stringToScan: String
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            stringToScan = String(hexString[start...])
        } else {
            stringToScan = hexString
        }

        let scanner = Scanner(string: stringToScan)

        var hex: UInt64 = 0
        scanner.scanHexInt64(&hex)

        self.init(hex: hex, opacity: opacity)
    }

    public var hexString: String? {
        @inline(__always)
        func colorComponentToUInt8(_ component: CGFloat) -> UInt8 {
            UInt8(max(0, min(255, (255 * component).rounded(.towardZero))))
        }

        let components = cgColor?.components

        let r: CGFloat = components?[0] ?? 0
        let g: CGFloat = components?[1] ?? 0
        let b: CGFloat = components?[2] ?? 0

        let alpha: CGFloat

        if components?.count == 4 {
            alpha = components?[3] ?? 1
        } else {
            alpha = 1
        }

        if alpha != 1 {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                colorComponentToUInt8(r),
                colorComponentToUInt8(g),
                colorComponentToUInt8(b),
                colorComponentToUInt8(alpha)
            )
        }

        return String(
            format: "#%02lX%02lX%02lX",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }

    // MARK: - string representation

    public init?(stringRepresentation: String) {
        var components = stringRepresentation
            .split(separator: " ")
            .map { Double($0) ?? 0 }
            .map { CGFloat($0) }

        if components.count < 4 {
            components += [1]
        }

        guard
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let color = CGColor(colorSpace: colorSpace, components: &components)
        else {
            return nil
        }

        self.init(color)
    }

    public var stringRepresentation: String? {
        guard
            let cgColor = cgColor,
            let components = cgColor.components
        else {
            return nil
        }

        let r = components.count > 0 ? components[0] : 0
        let g = components.count > 1 ? components[1] : 0
        let b = components.count > 2 ? components[2] : 0
        let alpha = cgColor.alpha

        return [r, g, b, alpha]
            .map { "\($0)" }
            .joined(separator: " ")
    }
}
