import SwiftUI

struct RootView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        if appViewModel.isSignedIn {
            AdaptiveContainer()
        } else {
            AuthView()
        }
    }
}
