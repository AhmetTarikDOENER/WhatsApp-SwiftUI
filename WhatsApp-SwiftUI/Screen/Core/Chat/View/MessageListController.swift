import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {
    
    //  MARK: - Properties
    private let cellIdentifier = "MessageListControllerCell"
    private let viewModel: ChatroomViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .gray.withAlphaComponent(0.3)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    //  MARK: - Init & Deinit
    init(_ viewModel: ChatroomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMessageListeners()
    }
    
    //  MARK: - Private
    private func setupViews() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func setupMessageListeners() {
        viewModel.$messages
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &subscriptions)
    }
}

//  MARK: - MessageListController+UITableViewDelegate,UITableViewDataSource
extension MessageListController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let message = viewModel.messages[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration {
            switch message.type {
            case .text:
                BubbleTextView(message: message)
            case .photo, .video:
                BubbleImageView(message: message)
            case .audio:
                BubbleAudioView(message: message)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

#Preview {
    MessageListView(.init(.placeholder))
}
