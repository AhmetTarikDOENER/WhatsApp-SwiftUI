import SwiftUI
import Kingfisher

struct CircularProfileImageView: View {
    
    //  MARK: - Properties
    let profileImageURL: String?
    let size: ImageSize
    let fallbackImage: FallbackImage
    
    //  MARK: - Init
    init(_ profileImageURL: String? = nil, size: ImageSize) {
        self.profileImageURL = profileImageURL
        self.size = size
        self.fallbackImage = .directChatIcon
    }
    
    var body: some View {
        if let profileImageURL {
            KFImage(URL(string: profileImageURL))
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
            case .mini: return 35
            case .xSmall: return 45
            case .small: return 55
            case .medium: return 65
            case .large: return 75
            case .xLarge: return 85
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
        self.profileImageURL = channel.circularProfileImageURL
        self.size = size
        self.fallbackImage = FallbackImage(for: channel.membersCount)
    }
}

#Preview {
    CircularProfileImageView(size: .custom(64))
}
