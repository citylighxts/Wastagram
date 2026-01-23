import SwiftUI
import CoreLocation

enum WasteType { case anorganic, organic }
enum CompostMethod { case returnBack, donate }
enum ScheduleType { case now, scheduled, subscribe }

struct Style {
    static let dash = StrokeStyle(lineWidth: 1, dash: [5])
}

// MARK: - Order Models
struct Order: Identifiable {
    let id: String
    let location: CLLocationCoordinate2D
    let address: String
    let weight: Double // dalam kg
    let wasteType: WasteType
    let timestamp: Date
    let customerName: String
}

// MARK: - Batch Suggestion
struct BatchSuggestion: Identifiable {
    let id = UUID()
    let orders: [Order]
    let totalWeight: Double
    let direction: String // "Utara", "Selatan", dll.
    
    var orderCount: Int {
        orders.count
    }
}
