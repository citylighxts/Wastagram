import SwiftUI

struct LandingView: View {
    @Binding var appState: ContentView.AppState
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.brandGreen, .darkGreen]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                Text("Wastagram").font(.system(size: 48, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("Sustainable - Grow - Future").font(.headline).foregroundColor(.white.opacity(0.9)).tracking(1.5)
                Spacer()
                
                Button(action: { appState = .auth }) {
                    Text("Get Started")
                        .font(.headline).foregroundColor(.darkGreen)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.white).cornerRadius(30).shadow(radius: 5)
                }
                .padding(.horizontal, 40).padding(.bottom, 50)
            }
        }
    }
}
