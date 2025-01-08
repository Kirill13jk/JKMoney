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
    
    /// Для Sign in with Apple (храним случайную «nonce», чтобы обеспечить безопасность)
    @State private var currentNonce: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("JKMoney")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Переключатель (Войти / Регистрация)
                Picker(selection: $authMode, label: Text("")) {
                    Text("Войти").tag(AuthMode.signIn)
                    Text("Регистрация").tag(AuthMode.signUp)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Поля ввода (для email и пароля)
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
                
                // Кнопка подтверждения (email/пароль)
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
                
                // Разделитель
                Divider()
                    .padding(.horizontal)
                
                // Кнопка «Войти с Apple ID»
                SignInWithAppleButton(
                    // Можно .signIn или .continue, на ваше усмотрение
                    .signIn,
                    onRequest: { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        
                        // Какие данные запрашиваем
                        request.requestedScopes = [.fullName, .email]
                        // Для безопасности прикрепляем 'nonce'
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
}

// MARK: - Основная логика
extension AuthView {
    
    // Обработка email/пароль
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
            // Авторизация успешна
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
    
    // MARK: - Apple Sign In
    private func handleAuthorization(_ authResults: ASAuthorization) {
        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
            // Уникальный ID пользователя в Apple
            let userId = appleIDCredential.user
            
            // Данные юзера (можете при желании сохранять):
            let email = appleIDCredential.email ?? "unknown@example.com"
            let fullName = appleIDCredential.fullName?.givenName ?? "User"
            
            // Например, сохраняем только userId
            appViewModel.signIn(userId: userId)
            
            // При желании — можете сохранить профайл в SwiftData (необязательно).
            // let userProfile = UserProfile(userId: userId, username: fullName, email: email)
            // modelContext.insert(userProfile)
            // try? modelContext.save()
        }
    }
    
    // Генерация nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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
    
    // Для безопасности (SHA256)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }
}
