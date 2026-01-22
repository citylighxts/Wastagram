import SwiftUI

struct MainAppView: View {
    @Binding var appState: ContentView.AppState
    @State private var selectedTab = 0
    
    @State private var showChatbot = false
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case 0: HomeView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    case 1: Text("Track Pickup Real-time").frame(maxWidth: .infinity, maxHeight: .infinity)
                    case 2: SetorView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    case 3: MarketplaceView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    case 4: profileTab
                    default: Text("Home")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))

                customNavBar
                
                chatbotButton
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .sheet(isPresented: $showChatbot) {
            ChatbotView()
        }
    }
    
    var topBar: some View {
        HStack {
            Text("Wastagram")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.darkGreen)
            Spacer()
            Button(action: { selectedTab = 4 }) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundColor(.brandGreen)
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
    }

    var customNavBar: some View {
        HStack(spacing: 0) {
            NavBarItem(icon: "house.fill", label: "Home", isSelected: selectedTab == 0) { selectedTab = 0 }
            NavBarItem(icon: "map.fill", label: "Track", isSelected: selectedTab == 1) { selectedTab = 1 }
            NavBarItem(icon: "arrow.up.bin.fill", label: "Setor", isSelected: selectedTab == 2, isSpecial: true) { selectedTab = 2 }
            NavBarItem(icon: "cart.fill", label: "Market", isSelected: selectedTab == 3) { selectedTab = 3 }
            NavBarItem(icon: "person.fill", label: "Profile", isSelected: selectedTab == 4) { selectedTab = 4 }
        }
        .padding(.top, 10)
        .padding(.bottom, 25)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.brandGreen, .darkGreen]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))
            .ignoresSafeArea(edges: .bottom)
        )
    }
    
    var chatbotButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showChatbot = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle().stroke(Color(hex: "2CAB02"), lineWidth: 3)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "2CAB02"))
                    }
                }
                .padding(.trailing, 25)
                .padding(.bottom, 95)
            }
        }
    }
    
    var profileTab: some View {
        VStack {
            Text("Profile Settings")
            Button("Log Out") {
                appState = .landing
            }
            .foregroundColor(.red)
            .padding()
        }
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView(appState: .constant(.main))
    }
}
