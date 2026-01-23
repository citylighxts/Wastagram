import SwiftUI
import MapKit

struct Step1TypeView: View {
    @Binding var selectedType: WasteType
    @Binding var selectedCategories: Set<String>
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Apa jenis sampahmu?").font(.title2).bold().foregroundColor(.darkGreen).padding(.top)
                VStack(spacing: 15) {
                    TypeSelectionCard(type: .anorganic, title: "Jemput Anorganik", subtitle: "Bank Sampah (Tukar Poin)", icon: "trash", isSelected: selectedType == .anorganic) { withAnimation { selectedType = .anorganic; selectedCategories = [] } }
                    TypeSelectionCard(type: .organic, title: "Jemput Organik", subtitle: "Rumah Kompos (Olah Limbah)", icon: "leaf.fill", isSelected: selectedType == .organic) { withAnimation { selectedType = .organic; selectedCategories = [] } }
                }.padding()
            }
        }
    }
}

struct Step2CategoryView: View {
    let selectedType: WasteType
    @Binding var selectedCategories: Set<String>
    @Binding var weight: String
    @Binding var bagCount: String
    @Binding var isSorted: Bool
    let anorganicCats = ["Plastik", "Kertas", "Kardus", "Logam", "Kaca", "Elektronik"]
    let organicCats = ["Sisa Makanan", "Daun Kering", "Kulit Buah", "Sisa Sayur", "Tulang"]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pilih Kategori Detail").font(.headline).foregroundColor(.darkGreen)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(selectedType == .anorganic ? anorganicCats : organicCats, id: \.self) { cat in
                            Button(action: { if selectedCategories.contains(cat) { selectedCategories.remove(cat) } else { selectedCategories.insert(cat) } }) {
                                Text(cat).font(.caption).fontWeight(.medium).padding(.vertical, 10).padding(.horizontal, 12).frame(maxWidth: .infinity).background(selectedCategories.contains(cat) ? Color.brandGreen : Color.white).foregroundColor(selectedCategories.contains(cat) ? .white : .gray).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brandGreen, lineWidth: selectedCategories.contains(cat) ? 0 : 1))
                            }
                        }
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Estimasi & Bukti").font(.headline).foregroundColor(.darkGreen)
                    HStack(spacing: 15) {
                        VStack(alignment: .leading) { Text("Berat (Kg)").font(.caption).foregroundColor(.gray); TextField("0", text: $weight).keyboardType(.decimalPad).padding().background(Color(.systemGray6)).cornerRadius(10) }
                        Text("ATAU").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                        VStack(alignment: .leading) { Text("Jml Kantong").font(.caption).foregroundColor(.gray); TextField("0", text: $bagCount).keyboardType(.numberPad).padding().background(Color(.systemGray6)).cornerRadius(10) }
                    }
                    Button(action: {}) { HStack { Image(systemName: "camera.fill"); Text("Ambil Foto Sampah") }.frame(maxWidth: .infinity).padding().background(Color(.systemGray6)).foregroundColor(.brandGreen).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.brandGreen, style: Style.dash)) }
                    Toggle(isOn: $isSorted) { Text("Sampah sudah dipilah bersih?").font(.subheadline).fontWeight(.medium) }.toggleStyle(SwitchToggleStyle(tint: .brandGreen))
                }
            }.padding()
        }
    }
}

struct Step3MethodView: View {
    let selectedType: WasteType
    @Binding var compostMethod: CompostMethod
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Mau diapakan sampahmu?").font(.title2).bold().foregroundColor(.darkGreen).padding(.top)
                if selectedType == .anorganic {
                    HStack {
                        Image(systemName: "banknote.fill").font(.title2).foregroundColor(.brandGreen)
                        VStack(alignment: .leading) { Text("Tukar Poin Wastagram").font(.headline); Text("Estimasi: 150 - 500 Poin").font(.caption).foregroundColor(.gray) }
                        Spacer(); Image(systemName: "checkmark.circle.fill").foregroundColor(.brandGreen)
                    }.padding().background(Color.brandGreen.opacity(0.1)).cornerRadius(12)
                } else {
                    VStack(spacing: 15) {
                        MethodRadioButton(title: "Kompos Dikembalikan", desc: "Dikirim balik (Rp 5.000)", isSelected: compostMethod == .returnBack) { compostMethod = .returnBack }
                        MethodRadioButton(title: "Donasi Kompos", desc: "Untuk taman kota", isSelected: compostMethod == .donate) { compostMethod = .donate }
                    }
                }
            }.padding()
        }
    }
}

struct Step4LocationView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var cameraPosition: MapCameraPosition
    @Binding var locationNote: String
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Di mana kami menjemput?").font(.title2).bold().foregroundColor(.darkGreen).padding(.top)
            ZStack(alignment: .bottomTrailing) {
                Map(position: $cameraPosition) { UserAnnotation() }
                .frame(height: 250).cornerRadius(15)
                .onReceive(locationManager.$region) { newRegion in withAnimation { cameraPosition = .region(newRegion) } }
                Button(action: { locationManager.requestLocation(); withAnimation { cameraPosition = .userLocation(fallback: .automatic) } }) {
                    Image(systemName: "location.fill").font(.title2).padding(12).background(Color.white).foregroundColor(.brandGreen).clipShape(Circle()).shadow(radius: 3)
                }.padding(10)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Alamat Terdeteksi:").font(.caption).foregroundColor(.gray)
                HStack { Image(systemName: "mappin.and.ellipse").foregroundColor(.red); Text(locationManager.userAddress ?? "Mencari lokasi...") }.padding().frame(maxWidth: .infinity, alignment: .leading).background(Color(.systemGray6)).cornerRadius(10)
            }
            TextField("Catatan Kurir (Cth: Pagar Hitam)", text: $locationNote).padding().background(Color(.systemGray6)).cornerRadius(10)
            Spacer()
        }.padding()
    }
}

struct Step5ScheduleView: View {
    @Binding var selectedSchedule: ScheduleType
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Kapan kami harus datang?").font(.title2).bold().foregroundColor(.darkGreen).padding(.top)
                VStack(spacing: 15) {
                    ScheduleCard(type: .now, label: "Jemput Sekarang", icon: "bolt.fill", selected: $selectedSchedule)
                    ScheduleCard(type: .scheduled, label: "Jadwalkan Nanti", icon: "calendar", selected: $selectedSchedule)
                    ScheduleCard(type: .subscribe, label: "Langganan Mingguan", icon: "arrow.triangle.2.circlepath", selected: $selectedSchedule)
                }
            }.padding()
        }
    }
}

struct Step6RecommendationView: View {
    let userLocation: CLLocationCoordinate2D?
    let wasteType: WasteType
    let wasteWeight: Double
    @Binding var selectedBank: BankSampahModel?
    
    @State private var recommendations: [BankSampahModel] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            VStack(alignment: .leading, spacing: 5) {
                Text("Pilih Mitra Pengepul")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.darkGreen)
                
                Text("Rekomendasi terbaik berdasarkan lokasi & jenis sampah Anda.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Logic Tampilan
            if isLoading {
                // UPDATE: Menggunakan maxHeight: .infinity agar mengisi layar
                // dan Spacer() akan mendorong konten ke tengah
                VStack {
                    Spacer()
                    ProgressView("Menganalisa data...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .brandGreen))
                        .scaleEffect(1.2)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if recommendations.isEmpty {
                // Tampilan Kosong (juga di-tengahin)
                VStack {
                    Spacer()
                    Image(systemName: "slash.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Tidak ditemukan mitra di area Anda.")
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else {
                // Tampilan List Hasil
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(recommendations) { bank in
                            BankSampahCard(bank: bank, isSelected: selectedBank?.id == bank.id)
                                .onTapGesture {
                                    withAnimation {
                                        selectedBank = bank
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120) // Ruang untuk tombol sticky bawah
                }
            }
        }
        // PENTING: Memastikan View utama mengisi seluruh layar
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Tambah durasi sedikit agar terlihat
            self.recommendations = RecommendationService.shared.getRecommendations(
                userLocation: userLocation,
                wasteType: wasteType,
                weight: wasteWeight
            )
            self.isLoading = false
            
            if selectedBank == nil {
                selectedBank = self.recommendations.first
            }
        }
    }
}

struct BankSampahCard: View {
    let bank: BankSampahModel
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(bank.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .brandGreen : .black)
                
                Text(bank.address)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Label(String(format: "%.1f", bank.rating), systemImage: "star.fill")
                        .font(.caption).foregroundColor(.orange)
                }
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isSelected ? .brandGreen : .gray.opacity(0.5))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.brandGreen : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}
