import SwiftUI
import AuthenticationServices
import CryptoKit

enum AuthMode {
    case signIn
    case signUp
}

struct AuthView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var authMode: AuthMode = .signIn
    @State private var currentNonce: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("JKMoney")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Picker(selection: $authMode, label: Text("")) {
                Text("Войти").tag(AuthMode.signIn)
                Text("Регистрация").tag(AuthMode.signUp)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Group {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                
                SecureField("Пароль", text: $password)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Button(action: {
                handleAuthButton()
            }) {
                Text(authMode == .signIn ? "Войти" : "Зарегистрироваться")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        handleAuthorization(authResults)
                    case .failure(let error):
                        print("Sign in with Apple error:", error.localizedDescription)
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}

extension AuthView {
    private func handleAuthButton() {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email или пароль пустые")
            return
        }
        switch authMode {
        case .signIn:
            signInManually()
        case .signUp:
            signUpManually()
        }
    }
    
    private func signInManually() {
        let savedEmail = UserDefaults.standard.string(forKey: "manualEmail")
        let savedPassword = UserDefaults.standard.string(forKey: "manualPassword")
        
        if email == savedEmail, password == savedPassword {
            let userId = "ManualUser_" + email
            appViewModel.signIn(userId: userId)
        } else {
            print("Неправильный email или пароль")
        }
    }
    
    private func signUpManually() {
        UserDefaults.standard.set(email, forKey: "manualEmail")
        UserDefaults.standard.set(password, forKey: "manualPassword")
        let userId = "ManualUser_" + email
        appViewModel.signIn(userId: userId)
    }
    
    private func handleAuthorization(_ authResults: ASAuthorization) {
        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            appViewModel.signIn(userId: userId)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. OSStatus \(errorCode)")
                }
                return random
            }
            for random in randoms {
                if remainingLength == 0 { break }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
