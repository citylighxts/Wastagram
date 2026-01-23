import SwiftUI
import CoreLocation

class BatchSuggestionViewModel: ObservableObject {
    @Published var currentBatchSuggestion: BatchSuggestion?
    @Published var showBatchSuggestion: Bool = false
    @Published var acceptedOrders: [Order] = []
    
    // Simulasi order yang ada (nanti bisa diganti dengan data real dari backend)
    @Published var availableOrders: [Order] = []
    
    // Parameter untuk menentukan "searah"
    private let maxDistanceForBatch: Double = 5000 // 5 km
    private let maxAngleDifference: Double = 45 // 45 derajat
    
    init() {
        // Simulasi order-order yang tersedia
        setupMockOrders()
    }
    
    // MARK: - Main Logic
    
    /// Cek apakah ada order yang searah setelah driver ambil satu order
    func checkForBatchOpportunities(currentOrder: Order) {
        let nearbyOrders = findNearbyOrders(from: currentOrder)
        
        if !nearbyOrders.isEmpty {
            let totalWeight = nearbyOrders.reduce(0) { $0 + $1.weight }
            let direction = getDirection(from: currentOrder.location, to: nearbyOrders.first!.location)
            
            let suggestion = BatchSuggestion(
                orders: nearbyOrders,
                totalWeight: totalWeight,
                direction: direction
            )
            
            DispatchQueue.main.async {
                self.currentBatchSuggestion = suggestion
                self.showBatchSuggestion = true
            }
        }
    }
    
    /// Mencari order yang searah dan berdekatan
    private func findNearbyOrders(from order: Order) -> [Order] {
        var nearbyOrders: [Order] = []
        
        for availableOrder in availableOrders {
            // Jangan sertakan order yang sama atau sudah diterima
            if availableOrder.id == order.id || acceptedOrders.contains(where: { $0.id == availableOrder.id }) {
                continue
            }
            
            let distance = calculateDistance(
                from: order.location,
                to: availableOrder.location
            )
            
            // Cek apakah dalam radius maksimal
            if distance <= maxDistanceForBatch {
                let angle = calculateBearing(
                    from: order.location,
                    to: availableOrder.location
                )
                
                // Cek apakah searah (bisa dikembangkan lebih lanjut)
                if isInSameDirection(angle: angle) {
                    nearbyOrders.append(availableOrder)
                }
            }
        }
        
        return nearbyOrders
    }
    
    /// Hitung jarak antara dua koordinat (dalam meter)
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    /// Hitung bearing/arah antara dua koordinat (dalam derajat)
    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        
        return bearing
    }
    
    /// Cek apakah arah berada dalam range yang searah
    private func isInSameDirection(angle: Double) -> Bool {
        // Logika sederhana: cek apakah dalam range tertentu
        // Bisa dikembangkan lebih kompleks sesuai kebutuhan
        return true
    }
    
    /// Konversi bearing ke arah mata angin
    private func getDirection(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> String {
        let bearing = calculateBearing(from: from, to: to)
        
        switch bearing {
        case 0..<22.5, 337.5...360:
            return "Utara"
        case 22.5..<67.5:
            return "Timur Laut"
        case 67.5..<112.5:
            return "Timur"
        case 112.5..<157.5:
            return "Tenggara"
        case 157.5..<202.5:
            return "Selatan"
        case 202.5..<247.5:
            return "Barat Daya"
        case 247.5..<292.5:
            return "Barat"
        case 292.5..<337.5:
            return "Barat Laut"
        default:
            return "Utara"
        }
    }
    
    // MARK: - Actions
    
    func acceptBatchSuggestion() {
        guard let suggestion = currentBatchSuggestion else { return }
        
        // Tambahkan order ke accepted orders
        acceptedOrders.append(contentsOf: suggestion.orders)
        
        // Hapus dari available orders
        availableOrders.removeAll { order in
            suggestion.orders.contains(where: { $0.id == order.id })
        }
        
        // Tutup suggestion
        showBatchSuggestion = false
        currentBatchSuggestion = nil
        
        print("✅ Batch diterima: \(suggestion.orderCount) orders, total \(suggestion.totalWeight) kg")
    }
    
    func declineBatchSuggestion() {
        showBatchSuggestion = false
        currentBatchSuggestion = nil
        print("❌ Batch ditolak")
    }
    
    // MARK: - Mock Data
    
    private func setupMockOrders() {
        // Simulasi order-order yang tersedia
        // Lokasi di sekitar Jakarta (contoh)
        availableOrders = [
            Order(
                id: "ORD001",
                location: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
                address: "Jl. Sudirman No. 10",
                weight: 2.5,
                wasteType: .anorganic,
                timestamp: Date(),
                customerName: "Ahmad"
            ),
            Order(
                id: "ORD002",
                location: CLLocationCoordinate2D(latitude: -6.2098, longitude: 106.8466),
                address: "Jl. Thamrin No. 5",
                weight: 1.8,
                wasteType: .anorganic,
                timestamp: Date(),
                customerName: "Budi"
            ),
            Order(
                id: "ORD003",
                location: CLLocationCoordinate2D(latitude: -6.2108, longitude: 106.8476),
                address: "Jl. MH Thamrin No. 15",
                weight: 0.7,
                wasteType: .organic,
                timestamp: Date(),
                customerName: "Citra"
            ),
            Order(
                id: "ORD004",
                location: CLLocationCoordinate2D(latitude: -6.1900, longitude: 106.8200),
                address: "Jl. Gatot Subroto No. 20",
                weight: 3.2,
                wasteType: .anorganic,
                timestamp: Date(),
                customerName: "Dewi"
            )
        ]
    }
    
    /// Tambah order baru secara dinamis (simulasi order yang datang)
    func addNewOrder(_ order: Order) {
        availableOrders.append(order)
        print("📦 Order baru masuk: \(order.id)")
    }
    
    /// Simulasi skenario: Driver baru saja ambil satu order
    func simulateDriverPickupOrder(orderId: String = "ORD001") {
        guard let currentOrder = availableOrders.first(where: { $0.id == orderId }) else {
            print("Order tidak ditemukan")
            return
        }
        
        print("🚚 Driver mengambil order: \(currentOrder.id)")
        
        // Hapus dari available
        availableOrders.removeAll { $0.id == orderId }
        
        // Cek apakah ada batch opportunity
        checkForBatchOpportunities(currentOrder: currentOrder)
    }
}
