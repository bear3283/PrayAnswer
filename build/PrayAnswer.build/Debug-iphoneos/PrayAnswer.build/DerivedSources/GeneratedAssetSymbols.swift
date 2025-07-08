import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AnsweredColor" asset catalog color resource.
    static let answered = DeveloperToolsSupport.ColorResource(name: "AnsweredColor", bundle: resourceBundle)

    /// The "FamilyColor" asset catalog color resource.
    static let family = DeveloperToolsSupport.ColorResource(name: "FamilyColor", bundle: resourceBundle)

    /// The "HealthColor" asset catalog color resource.
    static let health = DeveloperToolsSupport.ColorResource(name: "HealthColor", bundle: resourceBundle)

    /// The "NotAnsweredColor" asset catalog color resource.
    static let notAnswered = DeveloperToolsSupport.ColorResource(name: "NotAnsweredColor", bundle: resourceBundle)

    /// The "OtherColor" asset catalog color resource.
    static let other = DeveloperToolsSupport.ColorResource(name: "OtherColor", bundle: resourceBundle)

    /// The "PersonalColor" asset catalog color resource.
    static let personal = DeveloperToolsSupport.ColorResource(name: "PersonalColor", bundle: resourceBundle)

    /// The "PrimaryColor" asset catalog color resource.
    static let primary = DeveloperToolsSupport.ColorResource(name: "PrimaryColor", bundle: resourceBundle)

    /// The "RelationshipColor" asset catalog color resource.
    static let relationship = DeveloperToolsSupport.ColorResource(name: "RelationshipColor", bundle: resourceBundle)

    /// The "SecondaryColor" asset catalog color resource.
    static let secondary = DeveloperToolsSupport.ColorResource(name: "SecondaryColor", bundle: resourceBundle)

    /// The "ThanksgivingColor" asset catalog color resource.
    static let thanksgiving = DeveloperToolsSupport.ColorResource(name: "ThanksgivingColor", bundle: resourceBundle)

    /// The "VisionColor" asset catalog color resource.
    static let vision = DeveloperToolsSupport.ColorResource(name: "VisionColor", bundle: resourceBundle)

    /// The "WaitColor" asset catalog color resource.
    static let wait = DeveloperToolsSupport.ColorResource(name: "WaitColor", bundle: resourceBundle)

    /// The "WorkColor" asset catalog color resource.
    static let work = DeveloperToolsSupport.ColorResource(name: "WorkColor", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AnsweredColor" asset catalog color.
    static var answered: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .answered)
#else
        .init()
#endif
    }

    /// The "FamilyColor" asset catalog color.
    static var family: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .family)
#else
        .init()
#endif
    }

    /// The "HealthColor" asset catalog color.
    static var health: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .health)
#else
        .init()
#endif
    }

    /// The "NotAnsweredColor" asset catalog color.
    static var notAnswered: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .notAnswered)
#else
        .init()
#endif
    }

    /// The "OtherColor" asset catalog color.
    static var other: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .other)
#else
        .init()
#endif
    }

    /// The "PersonalColor" asset catalog color.
    static var personal: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .personal)
#else
        .init()
#endif
    }

    /// The "PrimaryColor" asset catalog color.
    static var primary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .primary)
#else
        .init()
#endif
    }

    /// The "RelationshipColor" asset catalog color.
    static var relationship: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .relationship)
#else
        .init()
#endif
    }

    /// The "SecondaryColor" asset catalog color.
    static var secondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .secondary)
#else
        .init()
#endif
    }

    /// The "ThanksgivingColor" asset catalog color.
    static var thanksgiving: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .thanksgiving)
#else
        .init()
#endif
    }

    /// The "VisionColor" asset catalog color.
    static var vision: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .vision)
#else
        .init()
#endif
    }

    /// The "WaitColor" asset catalog color.
    static var wait: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .wait)
#else
        .init()
#endif
    }

    /// The "WorkColor" asset catalog color.
    static var work: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .work)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AnsweredColor" asset catalog color.
    static var answered: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .answered)
#else
        .init()
#endif
    }

    /// The "FamilyColor" asset catalog color.
    static var family: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .family)
#else
        .init()
#endif
    }

    /// The "HealthColor" asset catalog color.
    static var health: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .health)
#else
        .init()
#endif
    }

    /// The "NotAnsweredColor" asset catalog color.
    static var notAnswered: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .notAnswered)
#else
        .init()
#endif
    }

    /// The "OtherColor" asset catalog color.
    static var other: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .other)
#else
        .init()
#endif
    }

    /// The "PersonalColor" asset catalog color.
    static var personal: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .personal)
#else
        .init()
#endif
    }

    /// The "PrimaryColor" asset catalog color.
    static var primary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .primary)
#else
        .init()
#endif
    }

    /// The "RelationshipColor" asset catalog color.
    static var relationship: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .relationship)
#else
        .init()
#endif
    }

    /// The "SecondaryColor" asset catalog color.
    static var secondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .secondary)
#else
        .init()
#endif
    }

    /// The "ThanksgivingColor" asset catalog color.
    static var thanksgiving: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .thanksgiving)
#else
        .init()
#endif
    }

    /// The "VisionColor" asset catalog color.
    static var vision: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .vision)
#else
        .init()
#endif
    }

    /// The "WaitColor" asset catalog color.
    static var wait: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .wait)
#else
        .init()
#endif
    }

    /// The "WorkColor" asset catalog color.
    static var work: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .work)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AnsweredColor" asset catalog color.
    static var answered: SwiftUI.Color { .init(.answered) }

    /// The "FamilyColor" asset catalog color.
    static var family: SwiftUI.Color { .init(.family) }

    /// The "HealthColor" asset catalog color.
    static var health: SwiftUI.Color { .init(.health) }

    /// The "NotAnsweredColor" asset catalog color.
    static var notAnswered: SwiftUI.Color { .init(.notAnswered) }

    /// The "OtherColor" asset catalog color.
    static var other: SwiftUI.Color { .init(.other) }

    /// The "PersonalColor" asset catalog color.
    static var personal: SwiftUI.Color { .init(.personal) }

    #warning("The \"PrimaryColor\" color asset name resolves to a conflicting Color symbol \"primary\". Try renaming the asset.")

    /// The "RelationshipColor" asset catalog color.
    static var relationship: SwiftUI.Color { .init(.relationship) }

    #warning("The \"SecondaryColor\" color asset name resolves to a conflicting Color symbol \"secondary\". Try renaming the asset.")

    /// The "ThanksgivingColor" asset catalog color.
    static var thanksgiving: SwiftUI.Color { .init(.thanksgiving) }

    /// The "VisionColor" asset catalog color.
    static var vision: SwiftUI.Color { .init(.vision) }

    /// The "WaitColor" asset catalog color.
    static var wait: SwiftUI.Color { .init(.wait) }

    /// The "WorkColor" asset catalog color.
    static var work: SwiftUI.Color { .init(.work) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AnsweredColor" asset catalog color.
    static var answered: SwiftUI.Color { .init(.answered) }

    /// The "FamilyColor" asset catalog color.
    static var family: SwiftUI.Color { .init(.family) }

    /// The "HealthColor" asset catalog color.
    static var health: SwiftUI.Color { .init(.health) }

    /// The "NotAnsweredColor" asset catalog color.
    static var notAnswered: SwiftUI.Color { .init(.notAnswered) }

    /// The "OtherColor" asset catalog color.
    static var other: SwiftUI.Color { .init(.other) }

    /// The "PersonalColor" asset catalog color.
    static var personal: SwiftUI.Color { .init(.personal) }

    /// The "RelationshipColor" asset catalog color.
    static var relationship: SwiftUI.Color { .init(.relationship) }

    /// The "ThanksgivingColor" asset catalog color.
    static var thanksgiving: SwiftUI.Color { .init(.thanksgiving) }

    /// The "VisionColor" asset catalog color.
    static var vision: SwiftUI.Color { .init(.vision) }

    /// The "WaitColor" asset catalog color.
    static var wait: SwiftUI.Color { .init(.wait) }

    /// The "WorkColor" asset catalog color.
    static var work: SwiftUI.Color { .init(.work) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

