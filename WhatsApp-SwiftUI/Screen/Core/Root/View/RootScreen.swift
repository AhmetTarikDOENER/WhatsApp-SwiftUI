import SwiftUI

struct RootScreen: View {
    
    //  MARK: - Property
    @StateObject private var viewModel = RootScreenViewModel()
    
    var body: some View {
        switch viewModel.authState {
        case .pending:
            ProgressView()
                .controlSize(.large)
        case .loggedIn(let loggedInUser):
            MainTabView()
        case .loggedOut:
            LoginScreen()
        }
    }
}

#Preview {
    RootScreen()
}
