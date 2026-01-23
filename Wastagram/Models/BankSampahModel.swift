import Foundation
import CoreLocation
import CoreML

// MARK: - 1. Update Data Model (Menyesuaikan kebutuhan ML)
struct BankSampahModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let rating: Double
    let acceptsUserWaste: Bool
    
    // Properti Tambahan untuk ML Features
    let operationalHours: Double // Durasi buka (contoh: 8.0 jam)
    let operationalDays: Double // Jumlah hari buka (contoh: 5.0 hari)
    let capacityKg: Double // Kapasitas harian
    
    // Harga per kategori (Sesuai PDF Harga Sampah)
    let pricePlastik: Double
    let priceKertas: Double
    let priceLogam: Double
    
    // Kemampuan menerima jenis sampah spesifik
    let acceptsPlastik: Bool
    let acceptsKertas: Bool
    let acceptsLogam: Bool
    let acceptsKaca: Bool
    let acceptsElektronik: Bool
    let acceptsOrganik: Bool
    
    var predictedScore: Double = 0.0
    
    static func == (lhs: BankSampahModel, rhs: BankSampahModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 2. Recommendation Service Updated
class RecommendationService {
    static let shared = RecommendationService()
    
    // Mock Data: Diisi nilai realistis berdasarkan PDF & Testing.ipynb
    private let allBanks = [
        BankSampahModel(
            name: "Bank Sampah Induk Surabaya",
            address: "Jl. Ngagel No. 10",
            coordinate: CLLocationCoordinate2D(latitude: -7.29, longitude: 112.74),
            rating: 4.8,
            acceptsUserWaste: true,
            operationalHours: 8.0,
            operationalDays: 6.0,
            capacityKg: 1000.0,
            pricePlastik: 3000.0, // Rata-rata dari PDF (Botol, Gelas)
            priceKertas: 1000.0,  // Rata-rata dari PDF (Koran, Kardus)
            priceLogam: 3500.0,   // Rata-rata dari PDF (Besi, Seng)
            acceptsPlastik: true, acceptsKertas: true, acceptsLogam: true,
            acceptsKaca: false, acceptsElektronik: false, acceptsOrganik: true
        ),
        BankSampahModel(
            name: "Bank Sampah Bintang Mangrove",
            address: "Jl. Rungkut Asri",
            coordinate: CLLocationCoordinate2D(latitude: -7.33, longitude: 112.78),
            rating: 4.5,
            acceptsUserWaste: true,
            operationalHours: 6.0,
            operationalDays: 5.0,
            capacityKg: 500.0,
            pricePlastik: 2500.0,
            priceKertas: 800.0,
            priceLogam: 3000.0,
            acceptsPlastik: true, acceptsKertas: true, acceptsLogam: true,
            acceptsKaca: false, acceptsElektronik: false, acceptsOrganik: false
        ),
        BankSampahModel(
            name: "Bank Sampah Lestari",
            address: "Jl. Ketintang",
            coordinate: CLLocationCoordinate2D(latitude: -7.31, longitude: 112.72),
            rating: 4.2,
            acceptsUserWaste: true,
            operationalHours: 7.0,
            operationalDays: 6.0,
            capacityKg: 300.0,
            pricePlastik: 2800.0,
            priceKertas: 900.0,
            priceLogam: 0.0, // Tidak terima logam
            acceptsPlastik: true, acceptsKertas: true, acceptsLogam: false,
            acceptsKaca: true, acceptsElektronik: false, acceptsOrganik: false
        )
    ]
    
    func getRecommendations(userLocation: CLLocationCoordinate2D?, wasteType: WasteType, weight: Double) -> [BankSampahModel] {
        guard let userLoc = userLocation else { return [] }
        
        var scoredBanks: [BankSampahModel] = []
        
        // Load Model
        let model = try? BankSampahRecommender(configuration: MLModelConfiguration())
        
        for var bank in allBanks {
            if !bank.acceptsUserWaste { continue }
            
            // --- Feature Engineering (Logic Python diterjemahkan ke Swift) ---
            
            // 1. Jarak & Distance Score (Exp Decay)
            let bankLoc = CLLocation(latitude: bank.coordinate.latitude, longitude: bank.coordinate.longitude)
            let myLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            let distanceKm = myLoc.distance(from: bankLoc) / 1000.0
            
            // Rumus: np.exp(-jarak_km / 10)
            let distanceScore = exp(-distanceKm / 10.0)
            
            // 2. Price Features
            let prices = [bank.pricePlastik, bank.priceKertas, bank.priceLogam].filter { $0 > 0 }
            let avgPrice = prices.isEmpty ? 0.0 : prices.reduce(0, +) / Double(prices.count)
            let maxPrice = prices.max() ?? 0.0
            let offersPricing = prices.isEmpty ? 0.0 : 1.0
            
            // 3. Operational Logic
            // Asumsi sederhana: Buka (1.0) untuk MVP. Nanti bisa pakai Date()
            let bukaSekarangBinary = 1.0
            
            // 4. Waste Types Count
            let wasteTypesCount = [bank.acceptsPlastik, bank.acceptsKertas, bank.acceptsLogam, bank.acceptsKaca, bank.acceptsElektronik, bank.acceptsOrganik].filter { $0 }.count
            
            var finalScore: Double = 0.0
            var usedML = false
            
            // --- CORE ML PREDICTION ---
            if let mlModel = model {
                do {
                    // INPUT HARUS LENGKAP sesuai Error Message
                    let input = BankSampahRecommenderInput(
                        jarak_km: distanceKm,
                        distance_score: distanceScore,
                        rating: bank.rating,
                        buka_sekarang_binary: bukaSekarangBinary,
                        operational_hours: bank.operationalHours,
                        num_operational_days: bank.operationalDays,
                        
                        accepts_plastik: bank.acceptsPlastik ? 1.0 : 0.0,
                        accepts_kertas: bank.acceptsKertas ? 1.0 : 0.0,
                        accepts_logam: bank.acceptsLogam ? 1.0 : 0.0,
                        accepts_kaca: bank.acceptsKaca ? 1.0 : 0.0,
                        accepts_elektronik: bank.acceptsElektronik ? 1.0 : 0.0,
                        accepts_organik: bank.acceptsOrganik ? 1.0 : 0.0,
                        num_waste_types: Double(wasteTypesCount),
                        
                        harga_plastik_per_kg: bank.pricePlastik,
                        harga_kertas_per_kg: bank.priceKertas,
                        harga_logam_per_kg: bank.priceLogam,
                        avg_price: avgPrice,
                        max_price: maxPrice,
                        offers_pricing: offersPricing,
                        
                        kapasitas_kg_per_hari: bank.capacityKg
                    )
                    
                    let output = try mlModel.prediction(input: input)
                    
                    // Ganti 'target' dengan nama output yg benar di .mlmodel (bisa 'score', 'identity', atau 'recommendation_score')
                    // Cek di Xcode: BankSampahRecommender > Predictions > Output
                    finalScore = output.recommendation_score
                    usedML = true
                } catch {
                    print("ML Error: \(error)")
                }
            }
            
            // Fallback jika ML gagal
            if !usedML {
                finalScore = (bank.rating * 20) + (avgPrice / 500) - (distanceKm * 5)
            }
            
            bank.predictedScore = finalScore
            scoredBanks.append(bank)
        }
        
        return scoredBanks.sorted { $0.predictedScore > $1.predictedScore }
    }
}
