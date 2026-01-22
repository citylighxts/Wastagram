import SwiftUI

struct NavBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    var isSpecial: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSpecial {
                        Circle()
                            .fill(Color(hex: "D1F813"))
                            .frame(width: 55, height: 55)
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    } else if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 45, height: 45)
                    }

                    Image(systemName: icon)
                        .font(.system(size: isSpecial ? 24 : 18, weight: .bold))
                        .foregroundColor(determineContentColor())
                }
                .offset(y: isSpecial ? -25 : 0)

                Text(label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected && !isSpecial ? .white : (isSpecial ? .white : .white.opacity(0.7)))
                    .offset(y: isSpecial ? -15 : 0)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .animation(.spring(), value: isSelected)
    }
    
    private func determineContentColor() -> Color {
        if isSpecial {
            return Color(hex: "124701")
        } else if isSelected {
            return Color(hex: "003D2E")
        } else {
            return .white
        }
    }
}
