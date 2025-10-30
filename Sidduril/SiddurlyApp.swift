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
        // Force RTL at the UIKit level for all views and controls
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
        UIScrollView.appearance().semanticContentAttribute = .forceRightToLeft
        UIToolbar.appearance().semanticContentAttribute = .forceRightToLeft
        
        // Set up RTL for the entire app using scene configuration
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.semanticContentAttribute = .forceRightToLeft
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
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
