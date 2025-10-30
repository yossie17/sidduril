struct ContentView: View {
    let prayers = PrayerLoader.loadAllPrayers()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.96, blue: 0.90).ignoresSafeArea()
                
                VStack(alignment: .trailing, spacing: 20) {
                    Text("🕊️ Siddurly")
                        .font(.custom("FrankRuhlLibre-Regular", size: 34))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .padding(.top, 30)
                    
                    ForEach(prayers) { prayer in
                        NavigationLink(destination: PrayerView(prayer: prayer)) {
                            Text(prayer.name)
                                .font(.custom("FrankRuhlLibre-Regular", size: 22))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding()
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(12)
                                .shadow(radius: 1)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("בחר תפילה")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

