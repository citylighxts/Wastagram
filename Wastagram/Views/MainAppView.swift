import SwiftUI

struct MainAppView: View {
    @Binding var appState: ContentView.AppState
    @State private var selectedTab = 0
    @State private var showChatbot = false
    @State private var chatbotPosition: CGPoint? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case 0: HomeView()
                    case 1: TrackView()
                    case 2: SetorView()
                    case 3: MarketplaceView()
                    case 4: profileTab
                    default: Text("Home")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))

                VStack {
                    topBar
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    customNavBar
                }
                
                chatbotButton(geometry: geometry)
            }
            .ignoresSafeArea(.keyboard)
            .coordinateSpace(name: "screenArea")
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
                .foregroundColor(.white)
            Spacer()
            Button(action: { selectedTab = 4 }) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.brandGreen, .darkGreen]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
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
        )
    }
    
    func chatbotButton(geometry: GeometryProxy) -> some View {
        Button(action: {
            showChatbot = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 55, height: 55)
                    .overlay(
                        Circle().stroke(Color(hex: "2CAB02"), lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "2CAB02"))
            }
        }
        .position(
            x: chatbotPosition?.x ?? geometry.size.width - 50,
            y: chatbotPosition?.y ?? geometry.size.height - 150
        )
        .gesture(
            DragGesture(coordinateSpace: .named("screenArea"))
                .onChanged { value in
                    self.chatbotPosition = value.location
                }
        )
        .animation(.interactiveSpring(), value: chatbotPosition)
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
