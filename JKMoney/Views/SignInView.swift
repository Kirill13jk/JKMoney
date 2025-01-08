import SwiftUI
import AuthenticationServices
import CryptoKit
import SwiftData

struct SignInView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var currentNonce: String?

    var body: some View {
        VStack {
            Text("Добро пожаловать в JKMoney!")
                .font(.title)
                .padding()

            Spacer()

            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    // Настраиваем запрос
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
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
            .padding()

            Spacer()
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func handleAuthorization(_ authResults: ASAuthorization) {
        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            _ = appleIDCredential.email ?? "unknown@example.com"
            _ = appleIDCredential.fullName?.givenName ?? "User"

            // При желании можно создать UserProfile в SwiftData
            // let userProfile = UserProfile(userId: userId, username: fullName, email: email)
            // modelContext.insert(userProfile)

            // Сохраняем userId для входа
            appViewModel.signIn(userId: userId)
        }
    }
}
