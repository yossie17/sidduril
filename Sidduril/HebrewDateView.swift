import SwiftUI

struct HebrewDateView: View {
    @State private var hebrewDate: String = ""
    @State private var dayOfWeek: String = ""
    
    private let hebrewCalendar = Calendar(identifier: .hebrew)
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "he")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Day of week
            Text(dayOfWeek)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Hebrew date
            Text(hebrewDate)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: 200)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
        .onAppear {
            updateDate()
        }
    }
    
    private func updateDate() {
        let now = Date()
        dayOfWeek = dayFormatter.string(from: now)
        hebrewDate = formatHebrewDate(now)
    }
    
    private func formatHebrewDate(_ date: Date) -> String {
        let components = hebrewCalendar.dateComponents([.day, .month, .year], from: date)
        
        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            return ""
        }
        
        let hebrewDay = hebrewNumber(day)
        let hebrewYear = hebrewNumber(year)
        let monthName = hebrewMonthName(month, year: year)
        
        return "\(hebrewDay) \(monthName) \(hebrewYear)"
    }
    
    private func hebrewNumber(_ number: Int) -> String {
        let ones = ["", "א", "ב", "ג", "ד", "ה", "ו", "ז", "ח", "ט"]
        let tens = ["", "י", "כ", "ל", "מ", "נ", "ס", "ע", "פ", "צ"]
        let hundreds = ["", "ק", "ר", "ש", "ת", "תק", "תר", "תש", "תת", "תתק"]
        
        var result = ""
        var num = number
        
        // For Hebrew years, we typically omit the thousands digit (5000)
        // So 5786 becomes 786 -> תשפ״ו
        if num >= 5000 && num < 6000 {
            num -= 5000
        }
        
        // Hundreds
        if num >= 100 {
            let hundredDigit = num / 100
            if hundredDigit < hundreds.count {
                result += hundreds[hundredDigit]
            }
            num %= 100
        }
        
        // Special cases for 15 and 16
        if num == 15 {
            result += "טו"
        } else if num == 16 {
            result += "טז"
        } else {
            // Tens
            if num >= 10 {
                let tenDigit = num / 10
                if tenDigit < tens.count {
                    result += tens[tenDigit]
                }
                num %= 10
            }
            
            // Ones
            if num > 0 && num < ones.count {
                result += ones[num]
            }
        }
        
        // Add gershayim
        if result.count > 1 {
            let index = result.index(result.endIndex, offsetBy: -1)
            result.insert(contentsOf: "״", at: index)
        } else if result.count == 1 {
            result += "׳"
        }
        
        return result
    }
    
    private func hebrewMonthName(_ month: Int, year: Int) -> String {
        let isLeapYear = hebrewCalendar.range(of: .month, in: .year, for: Date())?.count ?? 12 > 12
        
        let monthNames = [
            "תשרי", "חשון", "כסלו", "טבת", "שבט",
            isLeapYear ? "אדר א׳" : "אדר",
            isLeapYear ? "אדר ב׳" : "",
            "ניסן", "אייר", "סיון", "תמוז", "אב", "אלול"
        ].filter { !$0.isEmpty }
        
        if month > 0 && month <= monthNames.count {
            return monthNames[month - 1]
        }
        
        return ""
    }
}
