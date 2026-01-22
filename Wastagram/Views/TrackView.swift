import SwiftUI
import MapKit

struct TrackView: View {
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var courierLocation = CLLocationCoordinate2D(latitude: -6.2120, longitude: 106.8480)
    @State private var estimatedTime = "15 Menit"
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded = false
    
    let collapsedHeight: CGFloat = 215
    let expandedHeight: CGFloat = 500
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                UserAnnotation()
                Annotation("Kurir", coordinate: courierLocation) {
                    ZStack {
                        Circle().fill(.white).frame(width: 40, height: 40).shadow(radius: 3)
                        Image(systemName: "box.truck.badge.clock.fill")
                            .foregroundColor(.brandGreen)
                            .font(.title2)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .ignoresSafeArea()
            .padding(.bottom, collapsedHeight - 20)
            
            if isExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { isExpanded = false }
                    }
            }
            
            VStack(spacing: 0) {
                VStack {
                    Capsule()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = value.translation.height
                            if isExpanded {
                                dragOffset = max(0, newOffset)
                            } else {
                                dragOffset = min(0, newOffset)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if isExpanded {
                                    if value.translation.height > 100 { isExpanded = false }
                                } else {
                                    if value.translation.height < -50 { isExpanded = true }
                                }
                                dragOffset = 0
                            }
                        }
                )
                
                VStack(spacing: 20) {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                        
                        VStack(alignment: .leading) {
                            Text("Budi Santoso").font(.headline)
                            HStack {
                                Text("⭐ 4.9").font(.caption).bold().foregroundColor(.orange)
                                Text("• B 1234 CD").font(.caption).foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        
                        HStack(spacing: 10) {
                            Button(action: {}) {
                                Image(systemName: "phone.fill").padding(10).background(Color.green.opacity(0.1)).foregroundColor(.green).clipShape(Circle())
                            }
                            Button(action: {}) {
                                Image(systemName: "message.fill").padding(10).background(Color.brandGreen.opacity(0.1)).foregroundColor(.brandGreen).clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "clock.fill").foregroundColor(.brandGreen)
                                Text("Estimasi Tiba: \(estimatedTime)").font(.subheadline).bold()
                            }
                            
                            HStack(alignment: .top) {
                                VStack {
                                    Circle().fill(Color.brandGreen).frame(width: 10, height: 10)
                                    Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 2, height: 35)
                                    Circle().stroke(Color.gray, lineWidth: 2).frame(width: 10, height: 10)
                                }
                                VStack(alignment: .leading, spacing: 30) {
                                    VStack(alignment: .leading) {
                                        Text("Kurir Menuju Lokasi").font(.subheadline).bold()
                                        Text("Driver sedang dalam perjalanan").font(.caption).foregroundColor(.gray)
                                    }
                                    Text("Sampah Diangkut").font(.subheadline).foregroundColor(.gray)
                                }
                            }
                            
                            Text("Detail Pesanan").font(.headline).padding(.top)
                            HStack { Text("Jenis Sampah"); Spacer(); Text("Anorganik").bold() }
                            HStack { Text("Berat Estimasi"); Spacer(); Text("5 Kg").bold() }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .frame(height: isExpanded ? nil : 0)
                    .opacity(isExpanded ? 1 : 0)
                }
                .background(Color.white)
                
                Spacer()
            }
            .frame(height: isExpanded ? expandedHeight : collapsedHeight)
            .background(Color.white)
            .cornerRadius(25, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
            .offset(y: dragOffset)
        }
        .onAppear {
            startCourierSimulation()
        }
    }
    
    func startCourierSimulation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.linear(duration: 2.0)) {
                courierLocation.latitude += 0.0001
                courierLocation.longitude += 0.0001
                if Int.random(in: 1...10) > 8 { estimatedTime = "12 Menit" }
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView()
    }
}
