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
        VStack(alignment: .trailing, spacing: 12) {
            if let error = locationManager.locationError {
                Text(error)
                    .foregroundColor(.red)
            } else {
                timeRow(time: locationManager.sunrise, label: "זריחה", symbol: "sunrise.fill")
                
                Divider()
                
                timeRow(time: locationManager.sunset, label: "שקיעה", symbol: "sunset.fill")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: 200)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private func timeRow(time: Date?, label: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let time = time {
                    Text(dateFormatter.string(from: time))
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                } else {
                    Text("--:--")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Image(systemName: symbol)
                .font(.system(size: 28))
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}