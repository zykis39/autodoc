//
//  NewsFeedViewController.swift
//  autodoc
//
//  Created by Артём Зайцев on 08.04.2025.
//
import Combine
import UIKit

final class NewsFeedViewController: UIViewController {
    var collectionView: UICollectionView!
    var viewModel: NewsFeedViewModel!
    var cancellables: Set<AnyCancellable> = []

    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureCollectionView()
        viewModel.$news
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
        }.store(in: &cancellables)
        viewModel.getNews()
    }
        
    // MARK: - Private
    private func configureViewModel() {
        let service = NewsFeedService(base: "https://webapi.autodoc.ru/api/",
                                  paths: .init(feed: "news"))
        
        viewModel = NewsFeedViewModel(service: service,
                                      router: .init(navigationController: navigationController),
                                      showError: showError(error:),
                                      news: [],
                                      currentPage: 1)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(NewsFeedCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leadingConstraint = collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let constraints = [topConstraint, bottomConstraint, leadingConstraint, trailingConstraint]
        
        view.addConstraints(constraints)
        constraints.forEach { $0.isActive = true }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(isIPad ? 200 : 84))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isIPad ? 2 : 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func showError(error: NewsFeedServiceError) {}
}


// MARK: - UICollectionViewDataSource
extension NewsFeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.news.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NewsFeedCell else { return UICollectionViewCell() }
        let cellData = viewModel.news[indexPath.row]
        cell.configure(imageUrl: cellData.titleImageUrl, text: cellData.title)
        
        if indexPath.row == viewModel.news.count - 1 {
            viewModel.getNews()
        }
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension NewsFeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectElementAtIndex(indexPath.row)
    }
}
