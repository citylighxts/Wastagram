import SwiftUI
import MapKit
import CoreML // Import CoreML

struct SetorView: View {
    @StateObject private var locationManager = LocationManager()
    
    // UPDATE: Total steps jadi 6
    @State private var currentStep = 1
    @State private var totalSteps = 6
    @State private var showSuccessPopup = false
    @State private var moveRight = true
    
    // Data Form
    @State private var selectedType: WasteType = .anorganic
    @State private var selectedCategories: Set<String> = []
    @State private var weight: String = ""
    @State private var bagCount: String = ""
    @State private var isSorted: Bool = false
    @State private var compostMethod: CompostMethod = .donate
    @State private var locationNote: String = ""
    @State private var selectedSchedule: ScheduleType = .now
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // UPDATE: State untuk menyimpan Bank Sampah yang dipilih di Step 6
    @State private var selectedBankSampah: BankSampahModel? = nil

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header Navigasi
                    VStack(spacing: 10) {
                        HStack {
                            Button(action: prevStep) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(currentStep > 1 ? .darkGreen : .clear)
                            }
                            .disabled(currentStep == 1)
                            
                            Spacer()
                            Text(currentStep == 6 ? "Rekomendasi" : "Langkah \(currentStep) dari \(totalSteps)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.darkGreen)
                            Spacer()
                            
                            Image(systemName: "chevron.right").foregroundColor(.clear)
                        }
                        .padding(.horizontal)
                        
                        // Progress Bar
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
                    .padding(.top, 70)
                    .padding(.bottom, 20)
                    .background(Color.white)

                    // Area Form (Step Views)
                    ZStack {
                        switch currentStep {
                        case 1: Step1TypeView(selectedType: $selectedType, selectedCategories: $selectedCategories)
                        case 2: Step2CategoryView(selectedType: selectedType, selectedCategories: $selectedCategories, weight: $weight, bagCount: $bagCount, isSorted: $isSorted)
                        case 3: Step3MethodView(selectedType: selectedType, compostMethod: $compostMethod)
                        case 4: Step4LocationView(locationManager: locationManager, cameraPosition: $cameraPosition, locationNote: $locationNote)
                        case 5: Step5ScheduleView(selectedSchedule: $selectedSchedule)
                        case 6:
                            // UPDATE: Masuk ke halaman rekomendasi ML
                            Step6RecommendationView(
                                // HAPUS tanda '$' di sini
                                userLocation: locationManager.userLocation,
                                
                                wasteType: selectedType,
                                wasteWeight: Double(weight) ?? 0.0,
                                selectedBank: $selectedBankSampah // Ini tetap pakai '$' karena dia Binding
                            )
                        default: EmptyView()
                        }
                    }
                    .id(currentStep)
                    .transition(.asymmetric(
                        insertion: .move(edge: moveRight ? .trailing : .leading),
                        removal: .move(edge: moveRight ? .leading : .trailing)
                    ))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    Spacer().frame(height: 100)
                }
                .blur(radius: showSuccessPopup ? 4 : 0)
                .disabled(showSuccessPopup)

                // Tombol Bawah
                if !showSuccessPopup {
                    VStack {
                        Spacer()
                        Button(action: handleNextButton) {
                            // UPDATE: Text logika berubah
                            Text(currentStep == totalSteps ? "Pesan Penjemputan" : "Lanjut")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                // Disable tombol di step 6 jika belum pilih bank
                                .background(currentStep == 6 && selectedBankSampah == nil ? Color.gray : Color.brandGreen)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                        .disabled(currentStep == 6 && selectedBankSampah == nil)
                        .padding(.horizontal)
                        .padding(.bottom, 130)
                    }
                    .ignoresSafeArea(.keyboard)
                }

                if showSuccessPopup {
                    SuccessPopupView(show: $showSuccessPopup, action: resetForm)
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear { locationManager.checkIfLocationServicesIsEnabled() }
        }
    }
    
    // UPDATE: Logic button handler
    func handleNextButton() {
        if currentStep < totalSteps {
            nextStep()
        } else {
            // Hanya show success jika sudah di langkah terakhir (6)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showSuccessPopup = true
            }
        }
    }
    
    func nextStep() {
        moveRight = true
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep += 1
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
            }
        }
    }
}

struct SuccessPopupView: View {
    @Binding var show: Bool; let action: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.brandGreen)
                    .shadow(color: .brandGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 5) {
                    Text("Pesanan Diterima!").font(.title2).bold().foregroundColor(.darkGreen)
                    Text("Kurir Wastagram akan segera meluncur ke lokasi Anda.")
                        .font(.body).foregroundColor(.gray).multilineTextAlignment(.center)
                }
                
                Button(action: action) {
                    Text("Oke, Mantap!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandGreen)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(25)
            .frame(width: 320)
            .transition(.scale)
        }
        .zIndex(2)
    }
}

struct SetorView_Previews: PreviewProvider {
    static var previews: some View { SetorView() }
}
