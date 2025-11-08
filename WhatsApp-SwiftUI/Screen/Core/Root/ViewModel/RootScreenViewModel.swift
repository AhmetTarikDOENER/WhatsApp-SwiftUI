import Foundation
import Combine

final class RootScreenViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published private(set) var authState = AuthState.pending
    private var cancellable: AnyCancellable?
    
    //  MARK: - Init
    init() {
        cancellable = AuthenticationService.shared.authState.receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                self?.authState = authState
            }
    }
}
