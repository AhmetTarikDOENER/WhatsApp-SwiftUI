import SwiftUI

struct SettingsItemView: View {
    
    let settingsItem: SettingsItem
    
    var body: some View {
        HStack {
            iconImageView()
                .frame(width: 32, height: 32)
                .foregroundStyle(.white)
                .background(settingsItem.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            
            Text(settingsItem.title)
                .font(.system(size: 18))
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func iconImageView() -> some View {
        switch settingsItem.imageType {
        case .systemImage:
            Image(systemName: settingsItem.imageName)
                .bold()
                .font(.callout)
        case .assetImage:
            Image(settingsItem.imageName)
                .renderingMode(.template)
                .padding(3)
        }
    }
}

#Preview {
    SettingsItemView(settingsItem: .account)
}
