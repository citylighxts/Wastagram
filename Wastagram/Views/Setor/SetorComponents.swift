import SwiftUI

struct SectionHeader: View {
    let number: String; let title: String
    var body: some View {
        HStack {
            Circle().fill(Color.brandGreen).frame(width: 24, height: 24).overlay(Text(number).font(.caption).bold().foregroundColor(.white))
            Text(title).font(.headline).foregroundColor(.darkGreen)
        }
    }
}

struct TypeSelectionCard: View {
    let type: WasteType; let title: String; let subtitle: String; let icon: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).font(.largeTitle).foregroundColor(isSelected ? .white : .brandGreen).frame(width: 50)
                VStack(alignment: .leading) {
                    Text(title).font(.headline).foregroundColor(isSelected ? .white : .black)
                    Text(subtitle).font(.caption).foregroundColor(isSelected ? .white.opacity(0.9) : .gray)
                }
                Spacer()
                if isSelected { Image(systemName: "checkmark.circle.fill").foregroundColor(.white) }
            }
            .padding().background(isSelected ? Color.brandGreen : Color.white).cornerRadius(15).shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.brandGreen, lineWidth: isSelected ? 0 : 1))
        }
    }
}

struct MethodRadioButton: View {
    let title: String; let desc: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle").foregroundColor(isSelected ? .brandGreen : .gray)
                VStack(alignment: .leading) { Text(title).font(.subheadline).fontWeight(.semibold).foregroundColor(.black); Text(desc).font(.caption).foregroundColor(.gray) }
            }
            .padding().frame(maxWidth: .infinity, alignment: .leading).background(Color.white).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.brandGreen : Color(.systemGray5), lineWidth: 1))
        }
    }
}

struct ScheduleCard: View {
    let type: ScheduleType; let label: String; let icon: String; @Binding var selected: ScheduleType
    var body: some View {
        Button(action: { selected = type }) {
            HStack {
                Image(systemName: icon).font(.title2).foregroundColor(selected == type ? .white : .brandGreen)
                Text(label).font(.headline).fontWeight(.medium).foregroundColor(selected == type ? .white : .black)
                Spacer()
                if selected == type { Image(systemName: "checkmark").foregroundColor(.white) }
            }
            .frame(maxWidth: .infinity).padding().background(selected == type ? Color.brandGreen : Color.white).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandGreen, lineWidth: selected == type ? 0 : 1))
        }
    }
}

// MARK: - Batch Suggestion Card
struct BatchSuggestionCard: View {
    let suggestion: BatchSuggestion
    let onAccept: () -> Void
    let onDecline: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header dengan icon
            HStack {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundColor(.brandGreen)
                    .padding(10)
                    .background(Color.brandGreen.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saran Batch Pengambilan")
                        .font(.headline)
                        .foregroundColor(.darkGreen)
                    
                    Text("Efisiensi rute maksimal!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            }
            
            // Info pesanan
            HStack(spacing: 12) {
                // Jumlah order
                VStack(spacing: 4) {
                    Text("\(suggestion.orderCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.brandGreen)
                    Text("order")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.brandGreen.opacity(0.1))
                .cornerRadius(10)
                
                // Arah
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.brandGreen)
                    Text(suggestion.direction)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.brandGreen.opacity(0.1))
                .cornerRadius(10)
                
                // Berat total
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", suggestion.totalWeight))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.brandGreen)
                    Text("kg")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.brandGreen.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Pesan utama
            Text("Ada \(suggestion.orderCount) order searah + total \(String(format: "%.1f", suggestion.totalWeight)) kg → tambah rute?")
                .font(.subheadline)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            
            // Tombol aksi
            HStack(spacing: 12) {
                Button(action: onDecline) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Tidak")
                    }
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button(action: onAccept) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Tambah")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.brandGreen, Color.brandGreen.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .brandGreen.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.brandGreen.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}
