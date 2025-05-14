//
//  GalleryViewController.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Combine
import UIKit

final class GalleryViewController: UIViewController {
    private enum Constants {
        static let pageControlHeight: CGFloat = 44
        static let hInset: CGFloat = 16
        static let backgroundColor: UIColor = UIColor.init(hex: "#121214FF")!
        static let labelTextColor: UIColor = .white.withAlphaComponent(0.84)
        static let labelFontSize: CGFloat = 12
    }
    
    private lazy var collectionViewLayout = GalleryCompositionLayout()
    private lazy var collectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: collectionViewLayout)
        .set(\.backgroundColor, to: Constants.backgroundColor)
        .set(\.alwaysBounceVertical, to: false)
    private let subtitleLabel = UILabel()
        .set(\.numberOfLines, to: 0)
        .set(\.textAlignment, to: .center)
        .set(\.textColor, to: Constants.labelTextColor)
        .set(\.font, to: .systemFont(ofSize: Constants.labelFontSize))
    private let pageControl = UIPageControl()
    private let viewModel: GalleryViewModel
    private var cancellables: Set<AnyCancellable> = []
    private lazy var dataSource = GalleryDiffableDataSource(imageURLs: viewModel.imageURLs,
                                                            collectionView: collectionView)
    
    init(imageURLs: [URL], subtitle: String? = nil) {
        self.viewModel = GalleryViewModel(subtitle: subtitle, imageURLs: imageURLs)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        view.backgroundColor = Constants.backgroundColor
        [collectionView, subtitleLabel, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setupCollectionView()
        setupBindings()
        setupLayout()
    }
    
    private func setupCollectionView() {
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.reuseIdentifier)
        collectionView.dataSource = dataSource
    }
    
    private func setupBindings() {
        viewModel.$imageURLs
            .receive(on: DispatchQueue.main)
            .map { data in
                var snapshot = NSDiffableDataSourceSnapshot<Int, URL>()
                snapshot.appendSections([0])
                snapshot.appendItems(data.map { $0 })
                return snapshot
            }
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot)
            }
            .store(in: &cancellables)
        viewModel.$imageURLs
            .receive(on: DispatchQueue.main)
            .map { $0.count }
            .assign(to: \.numberOfPages, on: pageControl)
            .store(in: &cancellables)
        viewModel.$imageURLs
            .receive(on: DispatchQueue.main)
            .map { $0.count < 2 }
            .assign(to: \.isHidden, on: pageControl)
            .store(in: &cancellables)
        viewModel.$subtitle
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: subtitleLabel)
            .store(in: &cancellables)
        collectionViewLayout.currentPageSubject
            .assign(to: \.currentPage, on: pageControl)
            .store(in: &cancellables)
    }
    
    private func setupLayout() {
        let topConstraint = collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let leadingConstraint = collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let constraints = [topConstraint, leadingConstraint, trailingConstraint]
        view.addConstraints(constraints)
        constraints.forEach { $0.isActive = true }
        
        let slTopConstraint = subtitleLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor)
        let slBottomConstraint = subtitleLabel.bottomAnchor.constraint(equalTo: pageControl.safeAreaLayoutGuide.topAnchor)
        let slLeadingConstraint = subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.hInset)
        let slTrailingConstraint = subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.hInset)
        let slConstraints = [slTopConstraint, slBottomConstraint, slLeadingConstraint, slTrailingConstraint]
        view.addConstraints(slConstraints)
        slConstraints.forEach { $0.isActive = true }
        
        let pcBottomConstraint = pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let pcLeadingConstraint = pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let pcTrailingConstraint = pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let pcHeightConstraint = pageControl.heightAnchor.constraint(equalToConstant: Constants.pageControlHeight)
        let pcConstraints = [pcBottomConstraint, pcLeadingConstraint, pcTrailingConstraint, pcHeightConstraint]
        view.addConstraints(pcConstraints)
        pcConstraints.forEach { $0.isActive = true }
    }
}
