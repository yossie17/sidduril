import SwiftUI

struct SunTimesView: View {
    @StateObject private var locationManager = LocationManager()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if let error = locationManager.locationError {
                Text(error)
                    .foregroundColor(.red)
            } else {
                HStack(spacing: 16) {
                    timeView(time: locationManager.sunrise, label: "זריחה", symbol: "sunrise.fill")
                    timeView(time: locationManager.sunset, label: "שקיעה", symbol: "sunset.fill")
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 3)
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private func timeView(time: Date?, label: String, symbol: String) -> some View {
        HStack(spacing: 4) {
            if let time = time {
                Text(dateFormatter.string(from: time))
                    .font(.system(.body, design: .rounded))
            } else {
                Text("--:--")
                    .font(.system(.body, design: .rounded))
            }
            
            VStack(alignment: .trailing) {
                Image(systemName: symbol)
                    .foregroundColor(.orange)
                Text(label)
                    .font(.caption)
            }
        }
    }
}