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
