import SwiftUI

struct PrayerView: View {
    let prayer: Prayer
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text(prayer.name)
                .font(.custom("FrankRuhlLibre-Regular", size: 26))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .padding(.bottom, 6)
                .environment(\.layoutDirection, .rightToLeft)

            // Let the UITextView handle scrolling internally for best performance
            PrayerTextView(text: prayer.text, fontSize: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()

        .background(Color(red: 0.98, green: 0.96, blue: 0.90))
        .navigationTitle(prayer.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

