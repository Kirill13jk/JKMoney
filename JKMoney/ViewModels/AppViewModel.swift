import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    
    init() {
        if let _ = UserDefaults.standard.string(forKey: "userId") {
            self.isSignedIn = true
        }
    }
    
    func signIn(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userId")
        self.isSignedIn = true
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "userId")
        self.isSignedIn = false
    }
}
