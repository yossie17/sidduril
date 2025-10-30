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
        
        return urls.compactMap { url in
            let name = url.deletingPathExtension().lastPathComponent
            if let contents = try? String(contentsOf: url, encoding: .utf8) {
                return Prayer(name: displayName(from: name), text: contents)
            } else {
                return nil
            }
        }.sorted(by: { $0.name < $1.name })
    }
    
    private static func displayName(from filename: String) -> String {
        switch filename {
        case "shacharit": return "שחרית"
        case "mincha": return "מנחה"
        case "arvit": return "ערבית"
        default: return filename
        }
    }
}

