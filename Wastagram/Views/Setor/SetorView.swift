import SwiftUI
import MapKit

struct SetorView: View {
    @StateObject private var locationManager = LocationManager()
    
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
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showSuccessPopup = true
                                }
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
                        .padding(.bottom, 20)
                    }
                    .background(Color.white)
                }
                .blur(radius: showSuccessPopup ? 4 : 0)
                .disabled(showSuccessPopup)

                if showSuccessPopup {
                    SuccessPopupView(show: $showSuccessPopup, action: resetForm)
                }
            }
            .navigationBarHidden(true)
            .onAppear { locationManager.checkIfLocationServicesIsEnabled() }
        }
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
