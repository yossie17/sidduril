import SwiftUI

struct ContentView: View {
    @State private var prayers: [Prayer] = []
    
    init() {
        // Force RTL for navigation bar items
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.90, alpha: 1.0)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.96, blue: 0.90)
                    .ignoresSafeArea()

                VStack(alignment: .trailing, spacing: 16) {
                    Text("סידורלי")
                        .font(.custom("FrankRuhlLibre-Regular", size: 32))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 30)

                    ScrollView {
                        LazyVStack(alignment: .trailing, spacing: 12) {
                            ForEach(prayers) { prayer in
                                NavigationLink(destination: PrayerView(prayer: prayer)) {
                                    Text(prayer.name)
                                        .font(.custom("FrankRuhlLibre-Regular", size: 22))
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding()
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            // Load prayers off the main thread to avoid blocking UI
            prayers = await PrayerLoader.loadAllPrayersAsync()
        }
    }
}

