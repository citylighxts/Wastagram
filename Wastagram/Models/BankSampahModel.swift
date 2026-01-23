import Foundation
import CoreLocation
import CoreML

// MARK: - 1. Data Model
struct BankSampahModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let rating: Double
    let acceptsUserWaste: Bool
    
    // Properti Tambahan untuk ML Features
    let operationalHours: Double
    let operationalDays: Double
    let capacityKg: Double
    
    // Harga per kategori
    let pricePlastik: Double
    let priceKertas: Double
    let priceLogam: Double
    
    // Kemampuan menerima jenis sampah
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

// MARK: - 2. Recommendation Service (FIXED FOR PROTOTYPE)
class RecommendationService {
    static let shared = RecommendationService()
    
    // Mock Data (Data Dummy Prototype)
    private let allBanks = [
        BankSampahModel(
            name: "Bank Sampah Induk Surabaya",
            address: "Jl. Ngagel No. 10",
            coordinate: CLLocationCoordinate2D(latitude: -7.29, longitude: 112.74),
            rating: 4.8,
            acceptsUserWaste: true,
            operationalHours: 8.0, operationalDays: 6.0, capacityKg: 1000.0,
            pricePlastik: 3700.0, priceKertas: 1400.0, priceLogam: 3400.0,
            acceptsPlastik: true, acceptsKertas: true, acceptsLogam: true,
            acceptsKaca: false, acceptsElektronik: false, acceptsOrganik: true
        ),
        BankSampahModel(
            name: "Bank Sampah Bintang Mangrove",
            address: "Jl. Rungkut Asri",
            coordinate: CLLocationCoordinate2D(latitude: -7.33, longitude: 112.78),
            rating: 4.5,
            acceptsUserWaste: true,
            operationalHours: 6.0, operationalDays: 5.0, capacityKg: 500.0,
            pricePlastik: 2900.0, priceKertas: 1200.0, priceLogam: 3000.0,
            acceptsPlastik: true, acceptsKertas: true, acceptsLogam: true,
            acceptsKaca: false, acceptsElektronik: false, acceptsOrganik: false
        ),
        BankSampahModel(
            name: "Bank Sampah Lestari",
            address: "Jl. Ketintang",
            coordinate: CLLocationCoordinate2D(latitude: -7.31, longitude: 112.72),
            rating: 4.2,
            acceptsUserWaste: true,
            operationalHours: 7.0, operationalDays: 6.0, capacityKg: 300.0,
            pricePlastik: 3000.0, priceKertas: 1000.0, priceLogam: 0.0,
            acceptsPlastik: true, acceptsKertas: true, acceptsLogam: false,
            acceptsKaca: true, acceptsElektronik: false, acceptsOrganik: false
        ),
        BankSampahModel(
            name: "Bank Sampah Sejahtera",
            address: "Jl. Kenjeran",
            coordinate: CLLocationCoordinate2D(latitude: -7.25, longitude: 112.76),
            rating: 3.9,
            acceptsUserWaste: false, // Case: Tidak terima sampah
            operationalHours: 5.0, operationalDays: 5.0, capacityKg: 200.0,
            pricePlastik: 2000.0, priceKertas: 500.0, priceLogam: 2000.0,
            acceptsPlastik: true, acceptsKertas: true, acceptsLogam: true,
            acceptsKaca: false, acceptsElektronik: false, acceptsOrganik: false
        )
    ]
    
    func getRecommendations(userLocation: CLLocationCoordinate2D?, wasteType: WasteType, weight: Double) -> [BankSampahModel] {
        
        let defaultLocation = CLLocationCoordinate2D(latitude: -7.2575, longitude: 112.7521)
        let userLoc = userLocation ?? defaultLocation
        
        var scoredBanks: [BankSampahModel] = []
        
        // Load Model (Try/Catch agar aman)
        let model = try? BankSampahRecommender(configuration: MLModelConfiguration())
        
        for var bank in allBanks {
            // Filter 1: Apakah bank menerima sampah dari user?
            if !bank.acceptsUserWaste { continue }
            
            // Feature Engineering
            let bankLoc = CLLocation(latitude: bank.coordinate.latitude, longitude: bank.coordinate.longitude)
            let myLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            let distanceKm = myLoc.distance(from: bankLoc) / 1000.0
            
            // Logic tambahan untuk ML Input
            let distanceScore = exp(-distanceKm / 10.0)
            let prices = [bank.pricePlastik, bank.priceKertas, bank.priceLogam].filter { $0 > 0 }
            let avgPrice = prices.isEmpty ? 0.0 : prices.reduce(0, +) / Double(prices.count)
            let maxPrice = prices.max() ?? 0.0
            let offersPricing = prices.isEmpty ? 0.0 : 1.0
            let wasteTypesCount = [bank.acceptsPlastik, bank.acceptsKertas, bank.acceptsLogam, bank.acceptsKaca, bank.acceptsElektronik, bank.acceptsOrganik].filter { $0 }.count
            
            var finalScore: Double = 0.0
            var usedML = false
            
            // Core ML Prediction
            if let mlModel = model {
                do {
                    let input = BankSampahRecommenderInput(
                        jarak_km: distanceKm,
                        distance_score: distanceScore,
                        rating: bank.rating,
                        buka_sekarang_binary: 1.0, // Asumsi buka
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
                    
                    finalScore = output.recommendation_score
                    usedML = true
                } catch {
                    print("ML Error: \(error)")
                }
            }
            
            // Fallback Logic
            if !usedML {
                finalScore = (bank.rating * 20) + (avgPrice / 500) - (distanceKm * 5)
            }
            
            bank.predictedScore = finalScore
            scoredBanks.append(bank)
        }
        
        // Urutkan score tertinggi
        return scoredBanks.sorted { $0.predictedScore > $1.predictedScore }
    }
}
