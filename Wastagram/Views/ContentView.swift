import SwiftUI

struct ContentView: View {
    enum AppState {
        case landing, auth, main
    }
    
    @State private var appState: AppState = .landing
    
    var body: some View {
        ZStack {
            switch appState {
            case .landing:
                LandingView(appState: $appState)
                    .transition(.opacity)
            case .auth:
                AuthView(appState: $appState)
                    .transition(.move(edge: .trailing))
            case .main:
                MainAppView(appState: $appState)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: appState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
