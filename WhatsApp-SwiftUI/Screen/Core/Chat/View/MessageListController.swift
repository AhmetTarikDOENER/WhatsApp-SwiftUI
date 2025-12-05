import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {
    
    //  MARK: - Properties
    private let cellIdentifier = "MessageListControllerCell"
    private let viewModel: ChatroomViewModel
    private var subscriptions = Set<AnyCancellable>()
    private var lastScrollPositionID: String?
    private var startingFrame: CGRect?
    private var blurredEffectView: UIVisualEffectView?
    private var highlightedView: UIView?
    private var highlightedCell: UICollectionViewCell?
    private var reactionHostingViewController: UIViewController?
    private var contextMenuHostingViewController: UIViewController?
    
    private let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        listConfiguration.showsSeparators = false
        
        let section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        section.interGroupSpacing = -10
        
        return section
    }
    
    private lazy var messageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.refreshControl = pullToRefresh
        
        return collectionView
    }()
    
    private lazy var pullToRefresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: .chatbackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let pullDownIndicatorButton: UIButton = {
        var buttonConfiguration = UIButton.Configuration.filled()
        var imageConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfiguration)
        buttonConfiguration.image = image
        buttonConfiguration.baseBackgroundColor = .bubbleGreen
        buttonConfiguration.baseForegroundColor = .whatsAppBlack
        buttonConfiguration.imagePadding = 4
        buttonConfiguration.cornerStyle = .capsule
        let font = UIFont.systemFont(ofSize: 12, weight: .black)
        buttonConfiguration.attributedTitle = AttributedString(
            "Pull Down",
            attributes: AttributeContainer([
                NSAttributedString.Key.font: font])
        )
        let button = UIButton(configuration: buttonConfiguration)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
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
        view.backgroundColor = .clear
        setupViews()
        setupMessageListeners()
    }
    
    //  MARK: - Private
    private func setupViews() {
        view.addSubviews(backgroundImageView, messageCollectionView, pullDownIndicatorButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pullDownIndicatorButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            pullDownIndicatorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupMessageListeners() {
        viewModel.$messages
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.messageCollectionView.reloadData()
            }.store(in: &subscriptions)
        
        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messageCollectionView.scrollToLastItem(at: .bottom, animated: scrollRequest.isAnimated)
                }
            }.store(in: &subscriptions)
        
        viewModel.$isPaginating
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] isPaginating in
                guard let self, let lastScrollPositionID else { return }
                if isPaginating == false {
                    guard let index = viewModel.messages.firstIndex(where: { $0.id == lastScrollPositionID }) else { return }
                    let indexPath = IndexPath(item: index, section: 0)
                    self.messageCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.pullToRefresh.endRefreshing()
                }
            }.store(in: &subscriptions)
    }
    
    @objc private func pulledToRefresh() {
        lastScrollPositionID = viewModel.messages.first?.id
        viewModel.paginateMoreMessages()
    }
}

private extension UICollectionView {
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard numberOfItems(inSection: numberOfSections - 1) > 0 else { return }
        let lastSectionIndex = numberOfSections - 1
        let lastRowIndex = numberOfItems(inSection: lastSectionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        scrollToItem(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}

//  MARK: - MessageListController+UITableViewDelegate,UITableViewDataSource
extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        let message = viewModel.messages[indexPath.item]
        let isNewDay = viewModel.isNewDayToShowRelativeTimestamp(for: message, at: indexPath.item)
        let showSenderName = viewModel.showMessageSenderName(for: message, at: indexPath.item)
        cell.contentConfiguration = UIHostingConfiguration {
            BubbleView(
                message: message,
                channel: viewModel.channel,
                isNewDay: isNewDay,
                showSenderName: showSenderName
            )
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) else { return }
        /// Store selected cell's frame into startingFrame property
        startingFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        /// Take a snapshot of the selected cell and turns into a view to animate it later.
        guard let snapshotView = selectedCell.snapshotView(afterScreenUpdates: false) else { return }
        /// Assign the view from the stored frame
        highlightedView = UIView(frame: startingFrame ?? .zero)
        guard let highlightedView else { return }
        highlightedView.isUserInteractionEnabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMessageReactionView))

        /// Create blurred view
        let blurredEffect = UIBlurEffect(style: .regular)
        blurredEffectView = UIVisualEffectView(effect: blurredEffect)
        guard let blurredEffectView else { return }
        blurredEffectView.contentView.isUserInteractionEnabled = true
        blurredEffectView.contentView.addGestureRecognizer(tapGesture)
        blurredEffectView.alpha = 0
        
        highlightedCell = selectedCell
        highlightedCell?.alpha = 0
        
        /// Get the current window
        guard let window = UIWindowScene.currentWindowScene?.keyWindow else { return }
        window.addSubviews(blurredEffectView, highlightedView)
        highlightedView.addSubview(snapshotView)
        
        blurredEffectView.frame = window.frame

        let message = viewModel.messages[indexPath.item]
        attachContextMenuAndReaction(to: message, in: window)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseIn) { [weak self] in
                blurredEffectView.alpha = 1
                highlightedView.center.y = window.center.y - 70
                snapshotView.frame = highlightedView.bounds
                snapshotView.layer.applyShadow(color: .gray, opacity: 0.2, x: 0, y: 10, radius: 4)
            }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            pullDownIndicatorButton.alpha = viewModel.isPaginatable ? 1 : 0
        } else {
            pullDownIndicatorButton.alpha = 0
        }
    }
    
    @objc
    private func dismissMessageReactionView() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1,
            options: .curveEaseOut) { [weak self] in
                guard let self else { return }
                highlightedView?.frame = startingFrame ?? .zero
                blurredEffectView?.alpha = 0
                reactionHostingViewController?.view.removeFromSuperview()
                contextMenuHostingViewController?.view.removeFromSuperview()
            } completion: { [weak self] _ in
                self?.highlightedCell?.alpha = 1
                self?.blurredEffectView?.removeFromSuperview()
                self?.highlightedView?.removeFromSuperview()
                self?.highlightedCell = nil
                self?.blurredEffectView = nil
                self?.highlightedView = nil
            }
    }
    
    private func attachContextMenuAndReaction(to message: Message, in window: UIWindow) {
        guard let highlightedView, let startingFrame else { return }
        
        let reactionPickerView = ReactionPickerView(message: message)
        let reactionHostViewController = UIHostingController(rootView: reactionPickerView)
        reactionHostViewController.view.translatesAutoresizingMaskIntoConstraints = false
        reactionHostViewController.view.backgroundColor = .clear
        window.addSubview(reactionHostViewController.view)
        reactionHostViewController.view.bottomAnchor.constraint(equalTo: highlightedView.topAnchor, constant: -2).isActive = true
        reactionHostViewController.view.leadingAnchor.constraint(equalTo: highlightedView.leadingAnchor, constant: 20).isActive = message.direction == .received
        reactionHostViewController.view.trailingAnchor.constraint(equalTo: highlightedView.trailingAnchor, constant: -20).isActive = message.direction == .outgoing
        
        let contextMenuView = ContextMenuView(message: message)
        let contextMenuViewController = UIHostingController(rootView: contextMenuView)
        contextMenuViewController.view.backgroundColor = .clear
        contextMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(contextMenuViewController.view)
        contextMenuViewController.view.topAnchor.constraint(equalTo: highlightedView.bottomAnchor).isActive = true
        contextMenuViewController.view.leadingAnchor.constraint(equalTo: highlightedView.leadingAnchor, constant: 20).isActive = message.direction == .received
        contextMenuViewController.view.trailingAnchor.constraint(equalTo: highlightedView.trailingAnchor, constant: -20).isActive = message.direction == .outgoing
        
        self.reactionHostingViewController = reactionHostViewController
        self.contextMenuHostingViewController = contextMenuViewController
    }
}

//  MARK: - CALayer
extension CALayer {
    func applyShadow(color: UIColor, opacity: Float, x: CGFloat, y: CGFloat, radius: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = radius
    }
}

#Preview {
    MessageListView(.init(.placeholder))
        .ignoresSafeArea()
        .environmentObject(AudioMessagePlayer())
}
