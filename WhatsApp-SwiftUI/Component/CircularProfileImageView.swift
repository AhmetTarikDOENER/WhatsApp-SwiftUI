import SwiftUI
import Kingfisher

struct CircularProfileImageView: View {
    
    //  MARK: - Properties
    let profileImageUrl: String?
    let size: ImageSize
    let fallbackImage: FallbackImage
    
    //  MARK: - Init
    init(_ profileImageUrl: String? = nil, size: ImageSize) {
        self.profileImageUrl = profileImageUrl
        self.size = size
        self.fallbackImage = .directChatIcon
    }
    
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
        Image(systemName: fallbackImage.rawValue)
            .resizable()
            .scaledToFit()
            .imageScale(.large)
            .foregroundStyle(Color.placeholder)
            .frame(width: size.dimension, height: size.dimension)
            .background(.white)
            .clipShape(Circle())
    }
}

//  MARK: - CircularProfileImageView+ImageSize+FallbackImage
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
    
    enum FallbackImage: String {
        case directChatIcon = "person.circle.fill"
        case groupChatIcon = "person.2.circle.fill"
        
        init(for membersCount: Int) {
            switch membersCount {
            case 2: self = .directChatIcon
            default: self = .groupChatIcon
            }
        }
    }
}

//  MARK: - CircularProfileImageView+Init
extension CircularProfileImageView {
    init(_ channel: Channel, size: ImageSize) {
        self.profileImageUrl = channel.profileImageUrl
        self.size = size
        self.fallbackImage = FallbackImage(for: channel.membersCount)
    }
}

#Preview {
    CircularProfileImageView(size: .custom(64))
}
