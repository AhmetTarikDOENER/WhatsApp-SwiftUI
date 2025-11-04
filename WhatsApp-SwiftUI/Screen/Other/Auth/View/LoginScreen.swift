import SwiftUI

struct LoginScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                AuthenticationLogoView()
                
                AuthenticationTextField(text: .constant(""), type: .email)
                AuthenticationTextField(text: .constant(""), type: .password)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.teal.gradient)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LoginScreen()
}
