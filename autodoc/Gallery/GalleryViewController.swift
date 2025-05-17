//
//  GalleryViewController.swift
//  autodoc
//
//  Created by Артём Зайцев on 12.05.2025.
//

import Combine
import UIKit

final class GalleryViewController: UIViewController {
    private struct Config {
        static let pageControlHeight: CGFloat = 44
        static let hInset: CGFloat = 16
        static let backgroundColor: UIColor = UIColor.init(hex: "#121214FF")!
        static let labelTextColor: UIColor = .white.withAlphaComponent(0.84)
        static let labelFontSize: CGFloat = 12
    }
    
    private lazy var collectionViewLayout = GalleryCompositionLayout(layoutHandler: viewModel.configureInvalidation())
    private lazy var collectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: collectionViewLayout)
        .set(\.backgroundColor, to: Config.backgroundColor)
        .set(\.alwaysBounceVertical, to: false)
    private let subtitleLabel = UILabel()
        .set(\.numberOfLines, to: 0)
        .set(\.textAlignment, to: .center)
        .set(\.textColor, to: Config.labelTextColor)
        .set(\.font, to: .systemFont(ofSize: Config.labelFontSize))
    
    // FIXME: ограничить кол-во точек
    private let pageControl = UIPageControl()
        .set(\.hidesForSinglePage, to: true)
    private let viewModel: GalleryViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    init(imageURLs: [URL], subtitle: String? = nil) {
        self.viewModel = GalleryViewModel(subtitle: subtitle,
                                          imageURLs: imageURLs)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModel.onViewDidLoad()
    }
    
    // MARK: - Private
    private func setup() {
        view.backgroundColor = Config.backgroundColor
        [collectionView, subtitleLabel, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        subtitleLabel.text = viewModel.subtitle
        pageControl.numberOfPages = viewModel.imageURLs.count
        setupCollectionView()
        setupBindings()
        setupLayout()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = viewModel.makeDataSource(collectionView)
    }
    
    private func setupBindings() {
        viewModel.currentPageSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentPage in
                self?.pageControl.currentPage = currentPage
            }
            .store(in: &cancellables)
    }
    
    private func setupLayout() {
        let cvTopConstraint = collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let cvLeadingConstraint = collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let cvTrailingConstraint = collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let cvConstraints = [cvTopConstraint, cvLeadingConstraint, cvTrailingConstraint]
        view.addConstraints(cvConstraints)
        cvConstraints.forEach { $0.isActive = true }
        
        let slTopConstraint = subtitleLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor)
        let slBottomConstraint = subtitleLabel.bottomAnchor.constraint(equalTo: pageControl.safeAreaLayoutGuide.topAnchor)
        let slLeadingConstraint = subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Config.hInset)
        let slTrailingConstraint = subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Config.hInset)
        let slConstraints = [slTopConstraint, slBottomConstraint, slLeadingConstraint, slTrailingConstraint]
        view.addConstraints(slConstraints)
        slConstraints.forEach { $0.isActive = true }
        
        let pcBottomConstraint = pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let pcLeadingConstraint = pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let pcTrailingConstraint = pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let pcHeightConstraint = pageControl.heightAnchor.constraint(equalToConstant: Config.pageControlHeight)
        let pcConstraints = [pcBottomConstraint, pcLeadingConstraint, pcTrailingConstraint, pcHeightConstraint]
        view.addConstraints(pcConstraints)
        pcConstraints.forEach { $0.isActive = true }
    }
}
