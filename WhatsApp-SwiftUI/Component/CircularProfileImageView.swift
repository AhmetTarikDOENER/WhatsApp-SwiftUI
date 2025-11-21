import SwiftUI
import Kingfisher

struct CircularProfileImageView: View {
    
    //  MARK: - Property
    let profileImageUrl: String?
    let size: ImageSize
    
    var body: some View {
        if let profileImageUrl {
            KFImage(URL(string: profileImageUrl))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
        } else {
            placeholderImageView()
        }
    }
    
    //  MARK: - Private
    private func placeholderImageView() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .imageScale(.large)
            .foregroundStyle(Color.placeholder)
            .frame(width: size.dimension, height: size.dimension)
            .background(.white)
            .clipShape(Circle())
    }
}

//  MARK: - CircularProfileImageView+ImageSize
extension CircularProfileImageView {
    enum ImageSize {
        case mini, xSmall, small, medium, large, xLarge
        case custom(CGFloat)
        
        var dimension: CGFloat {
            switch self {
            case .mini: return 24
            case .xSmall: return 34
            case .small: return 44
            case .medium: return 54
            case .large: return 64
            case .xLarge: return 74
            case .custom(let size): return size
            }
        }
    }
}

#Preview {
    CircularProfileImageView(profileImageUrl: nil, size: .custom(64))
}
