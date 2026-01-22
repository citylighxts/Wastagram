import SwiftUI

struct AuthView: View {
    @Binding var appState: ContentView.AppState
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            Text(isLoginMode ? "Welcome" : "Create Account")
                .font(.largeTitle).fontWeight(.bold).foregroundColor(.darkGreen)
            
            VStack(spacing: 15) {
                TextField("Email Address", text: $email)
                    .padding().background(Color(.systemGray6)).cornerRadius(10)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding().background(Color(.systemGray6)).cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: { appState = .main }) {
                Text(isLoginMode ? "Log In" : "Sign Up")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.brandGreen).cornerRadius(15)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: { withAnimation { isLoginMode.toggle() } }) {
                Text(isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Log in")
                    .font(.subheadline).foregroundColor(.gray)
            }
            .padding(.bottom, 20)
        }
    }
}
