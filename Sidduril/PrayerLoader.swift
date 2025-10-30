import Foundation

struct Prayer: Identifiable {
    let id = UUID()
    let name: String
    let text: String
}

class PrayerLoader {
    static func loadAllPrayers() -> [Prayer] {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "txt", subdirectory: nil) else {
            return []
        }
        
        // Load all prayers into a dictionary
        var prayerDict: [String: Prayer] = [:]
        for url in urls {
            let filename = url.deletingPathExtension().lastPathComponent
            if let contents = try? String(contentsOf: url, encoding: .utf8) {
                let prayer = Prayer(name: displayName(from: filename), text: contents)
                prayerDict[filename] = prayer
            }
        }
        
        // Define the specific order
        let order = ["shacharit", "mincha", "arvit", "birkathamazon"]
        
        // Return prayers in the specified order
        return order.compactMap { prayerDict[$0] }
    }

    /// Async wrapper that loads prayers off the main thread to avoid blocking UI.
    static func loadAllPrayersAsync() async -> [Prayer] {
        return await Task.detached {
            return loadAllPrayers()
        }.value
    }
    
    private static func displayName(from filename: String) -> String {
        switch filename {
        case "shacharit": return "שחרית"
        case "mincha": return "מנחה"
        case "arvit": return "ערבית"
        case "birkathamazon": return "ברכת המזון"
        default: return filename
        }
    }
}

