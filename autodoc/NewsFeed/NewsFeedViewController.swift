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
    lazy var datasource = makeDataSource()

    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureCollectionView()
        viewModel.$data
            .receive(on: DispatchQueue.main)
            .map { data in
                var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
                snapshot.appendSections([0])
                snapshot.appendItems(data.map { $0.id })
                return snapshot
            }
            .sink { [weak self] snapshot in
                self?.datasource.apply(snapshot)
            }
            .store(in: &cancellables)
        viewModel.getNews()
    }
        
    // MARK: - Private
    private func configureViewModel() {
        let service = NewsFeedService(base: "https://webapi.autodoc.ru/api/",
                                  paths: .init(feed: "news"))
        
        viewModel = NewsFeedViewModel(service: service,
                                      router: .init(navigationController: navigationController),
                                      showError: showError(error:),
                                      currentPage: 1)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(NewsFeedCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        collectionView.dataSource = datasource
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
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, Int> {
        UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) { [viewModel] collectionView, indexPath, itemIdentifier in
            guard let viewModel,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NewsFeedCell,
                  let cellData = viewModel.data.first(where: { $0.id == itemIdentifier }) else { return UICollectionViewCell() }
            cell.configure(imageUrl: cellData.titleImageUrl, text: cellData.title)
            return cell
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(isIPad ? 0.5 : 1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(isIPad ? 200 : 84)) // 20pt  -vertical
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: isIPad ? 2 : 1)
        group.interItemSpacing = .fixed(20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func showError(error: NewsFeedServiceError) {}
}


// MARK: - UICollectionViewDelegate
extension NewsFeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectElementAtIndex(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.data.count - 1 {
            viewModel.getNews()
        }
    }
}
