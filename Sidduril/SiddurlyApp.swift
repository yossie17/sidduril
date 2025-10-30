import SwiftUI
import UIKit

/// Make sure all UI elements, including system bars and menus, respect RTL layout
extension UIApplication {
    var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        get { .rightToLeft }
        set { }
    }
}

@main
struct SiddurlyApp: App {
    init() {
        // Force RTL for the entire application interface
        UserDefaults.standard.set(["he"] as NSArray, forKey: "AppleLanguages")
        UserDefaults.standard.set("he", forKey: "AppleLocale")
        
        // Force RTL at the UIKit level for all views and controls
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
        UIScrollView.appearance().semanticContentAttribute = .forceRightToLeft
        UIToolbar.appearance().semanticContentAttribute = .forceRightToLeft
        UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
        UITableView.appearance().semanticContentAttribute = .forceRightToLeft
        UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
        
        // Override the system RTL settings
        UserDefaults.standard.set(true, forKey: "AppleTextDirection")
        UserDefaults.standard.set(true, forKey: "NSForceRightToLeftWritingDirection")
        
        // Set up RTL for the entire app using scene configuration
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.semanticContentAttribute = .forceRightToLeft
                window.rootViewController?.view.semanticContentAttribute = .forceRightToLeft
                for subview in window.subviews {
                    subview.semanticContentAttribute = .forceRightToLeft
                }
            }
        }
        
        // Set navigation bar appearance to match app theme
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.90, alpha: 1.0)
        navBarAppearance.titleTextAttributes = [
            .font: UIFont(name: "FrankRuhlLibre-Regular", size: 20) ?? .systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        navBarAppearance.backButtonAppearance.normal.titleTextAttributes = [
            .font: UIFont(name: "FrankRuhlLibre-Regular", size: 17) ?? .systemFont(ofSize: 17)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Force RTL for navigation
        UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.layoutDirection, .rightToLeft)
                .flipsForRightToLeftLayoutDirection(true)
        }
    }
}
