import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Hello, Zaky! 🌿")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Ready to save the planet today?")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
                
            }
        }
    }
}
