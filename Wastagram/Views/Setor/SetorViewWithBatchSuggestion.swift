import SwiftUI
import MapKit

/// Example: SetorView dengan integrasi Batch Suggestion
struct SetorViewWithBatchSuggestion: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var batchViewModel = BatchSuggestionViewModel()
    
    @State private var currentStep = 1
    @State private var totalSteps = 5
    @State private var showSuccessPopup = false
    @State private var moveRight = true
    
    @State private var selectedType: WasteType = .anorganic
    @State private var selectedCategories: Set<String> = []
    @State private var weight: String = ""
    @State private var bagCount: String = ""
    @State private var isSorted: Bool = false
    @State private var compostMethod: CompostMethod = .donate
    @State private var locationNote: String = ""
    @State private var selectedSchedule: ScheduleType = .now
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // State untuk tracking order yang baru dibuat
    @State private var justCreatedOrderId: String?

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        HStack {
                            Button(action: prevStep) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(currentStep > 1 ? .darkGreen : .clear)
                            }
                            .disabled(currentStep == 1)
                            
                            Spacer()
                            Text("Langkah \(currentStep) dari \(totalSteps)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.darkGreen)
                            Spacer()
                            
                            Image(systemName: "chevron.right").foregroundColor(.clear)
                        }
                        .padding(.horizontal)
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 6)
                                Rectangle().fill(Color.brandGreen)
                                    .frame(width: geo.size.width * (CGFloat(currentStep) / CGFloat(totalSteps)), height: 6)
                                    .animation(.smooth, value: currentStep)
                            }
                            .cornerRadius(3)
                        }
                        .frame(height: 6)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 20)
                    .background(Color.white)

                    ZStack {
                        switch currentStep {
                        case 1: Step1TypeView(selectedType: $selectedType, selectedCategories: $selectedCategories)
                        case 2: Step2CategoryView(selectedType: selectedType, selectedCategories: $selectedCategories, weight: $weight, bagCount: $bagCount, isSorted: $isSorted)
                        case 3: Step3MethodView(selectedType: selectedType, compostMethod: $compostMethod)
                        case 4: Step4LocationView(locationManager: locationManager, cameraPosition: $cameraPosition, locationNote: $locationNote)
                        case 5: Step5ScheduleView(selectedSchedule: $selectedSchedule)
                        default: EmptyView()
                        }
                    }
                    .id(currentStep)
                    .transition(.asymmetric(
                        insertion: .move(edge: moveRight ? .trailing : .leading),
                        removal: .move(edge: moveRight ? .leading : .trailing)
                    ))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)

                    VStack {
                        Button(action: {
                            if currentStep < totalSteps {
                                nextStep()
                            } else {
                                submitOrder()
                            }
                        }) {
                            Text(currentStep == totalSteps ? "Pesan Penjemputan" : "Lanjut")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brandGreen)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .background(Color.white)
                }
                .blur(radius: showSuccessPopup ? 4 : 0)
                .disabled(showSuccessPopup)

                // Success Popup
                if showSuccessPopup {
                    SuccessPopupView(show: $showSuccessPopup, action: resetForm)
                }
                
                // 🎯 BATCH SUGGESTION OVERLAY
                if batchViewModel.showBatchSuggestion,
                   let suggestion = batchViewModel.currentBatchSuggestion {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack {
                        Spacer()
                        
                        BatchSuggestionCard(
                            suggestion: suggestion,
                            onAccept: {
                                withAnimation(.spring()) {
                                    batchViewModel.acceptBatchSuggestion()
                                    // Optional: Show confirmation
                                    showBatchAcceptedFeedback()
                                }
                            },
                            onDecline: {
                                withAnimation(.spring()) {
                                    batchViewModel.declineBatchSuggestion()
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        Spacer()
                            .frame(height: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                locationManager.checkIfLocationServicesIsEnabled()
                
                // 🔥 Simulasi: Check for batch opportunities saat view muncul
                // Dalam production, ini akan triggered dari notification/backend
                simulateCheckBatchOpportunities()
            }
        }
        .animation(.spring(), value: batchViewModel.showBatchSuggestion)
    }
    
    func nextStep() {
        if currentStep < totalSteps {
            moveRight = true
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep += 1
            }
        }
    }
    
    func prevStep() {
        if currentStep > 1 {
            moveRight = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep -= 1
            }
        }
    }
    
    func submitOrder() {
        // Create order and trigger batch suggestion check
        let newOrderId = createOrder()
        justCreatedOrderId = newOrderId
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showSuccessPopup = true
        }
        
        // 🎯 TRIGGER BATCH SUGGESTION CHECK
        // Delay sedikit agar success popup muncul dulu
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            checkForBatchSuggestionAfterSubmit(orderId: newOrderId)
        }
    }
    
    func createOrder() -> String {
        // Simulasi create order
        let orderId = "ORD-\(UUID().uuidString.prefix(8))"
        
        // Dalam production, ini akan hit backend API
        print("✅ Order created: \(orderId)")
        print("   Type: \(selectedType)")
        print("   Weight: \(weight) kg")
        print("   Location: \(locationNote)")
        
        return orderId
    }
    
    func checkForBatchSuggestionAfterSubmit(orderId: String) {
        // Simulasi order yang baru dibuat
        let currentOrder = Order(
            id: orderId,
            location: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
            address: locationNote.isEmpty ? "Lokasi saat ini" : locationNote,
            weight: Double(weight) ?? 0,
            wasteType: selectedType,
            timestamp: Date(),
            customerName: "You"
        )
        
        // Check for batch opportunities
        batchViewModel.checkForBatchOpportunities(currentOrder: currentOrder)
    }
    
    func simulateCheckBatchOpportunities() {
        // Simulasi skenario untuk testing
        // Dalam production, ini akan triggered oleh:
        // 1. WebSocket notification dari backend
        // 2. Push notification
        // 3. Polling backend API
        
        // Example: Simulate after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let firstAvailableOrder = batchViewModel.availableOrders.first {
                // Uncomment to test
                // batchViewModel.checkForBatchOpportunities(currentOrder: firstAvailableOrder)
            }
        }
    }
    
    func showBatchAcceptedFeedback() {
        // Optional: Show toast or brief feedback
        print("🎉 Batch diterima! Order ditambahkan ke rute.")
        
        // Bisa tambahkan haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func resetForm() {
        withAnimation {
            showSuccessPopup = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentStep = 1
                selectedType = .anorganic
                selectedCategories = []
                weight = ""
                bagCount = ""
                isSorted = false
                locationNote = ""
                selectedSchedule = .now
                justCreatedOrderId = nil
            }
        }
    }
}

// MARK: - Example Integration Points

/// Extension untuk integrasi dengan backend
extension SetorViewWithBatchSuggestion {
    
    /// Call this when receiving new order notification from backend
    func onNewOrderNotification(orderData: [String: Any]) {
        // Parse order dari backend
        guard let order = parseOrderFromBackend(orderData) else { return }
        
        // Add to available orders
        batchViewModel.addNewOrder(order)
        
        // Check if should show batch suggestion
        if let currentOrder = getCurrentActiveOrder() {
            batchViewModel.checkForBatchOpportunities(currentOrder: currentOrder)
        }
    }
    
    /// Parse order dari backend response
    func parseOrderFromBackend(_ data: [String: Any]) -> Order? {
        // Implementation untuk parse dari JSON
        // Example structure:
        guard let id = data["id"] as? String,
              let lat = data["latitude"] as? Double,
              let lng = data["longitude"] as? Double,
              let address = data["address"] as? String,
              let weight = data["weight"] as? Double else {
            return nil
        }
        
        return Order(
            id: id,
            location: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            address: address,
            weight: weight,
            wasteType: data["type"] as? String == "organic" ? .organic : .anorganic,
            timestamp: Date(),
            customerName: data["customer_name"] as? String ?? "Unknown"
        )
    }
    
    /// Get current active order (order yang baru di-pickup atau dibuat)
    func getCurrentActiveOrder() -> Order? {
        // Implementation untuk get current order
        // Bisa dari local state atau fetch dari backend
        
        if let orderId = justCreatedOrderId {
            // Find order by ID
            return batchViewModel.availableOrders.first { $0.id == orderId }
        }
        
        return nil
    }
}

struct SetorViewWithBatchSuggestion_Previews: PreviewProvider {
    static var previews: some View {
        SetorViewWithBatchSuggestion()
    }
}
