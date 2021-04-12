//
//  ViewController.swift
//  DiffableDataSource_Example
//
//  Created by Zedd on 2021/04/06.
//

import UIKit
import Foundation

struct DJ: Hashable {
    
    let id = UUID()
    var name: String
}

class ViewController: UIViewController {
    
    enum Section: CaseIterable {
        case main
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var nameArr = ["Zedd", "Alan Walker", "David Guetta", "Avicii", "Marshmello", "Steve Aoki", "R3HAB", "Armin van Buuren", "Skrillex", "Illenium", "The Chainsmokers", "Don Diablo", "Zedd", "Afrojack", "Tiesto", "KSHMR", "DJ Snake", "Kygo", "Galantis", "Major Lazer", "Vicetone"
    ]
    
    lazy var arr: [DJ] = {
        return self.nameArr.map { DJ(name: $0) }
    }()
        
    var dataSource: UICollectionViewDiffableDataSource<Section, DJ>!
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.collectionViewLayout = self.createLayout()
        self.setupSearchController()
        self.setupDataSource()
        self.performQuery(with: nil)
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        self.navigationItem.searchController?.searchResultsUpdater = self
        self.navigationItem.title = "Search DJ"
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupDataSource() {
        // MARK: - Way 1
        self.collectionView.register(DJCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.dataSource =
            UICollectionViewDiffableDataSource<Section, DJ>(collectionView: self.collectionView) { (collectionView, indexPath, person) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DJCollectionViewCell else { preconditionFailure() }
                cell.configure(text: person.name)
            return cell
        }
        
        // MARK: - Way 2
        
//        let cellRegistration = UICollectionView.CellRegistration
//        <DJCollectionViewCell, DJ> { (cell, indexPath, dj) in
//            cell.configure(text: dj.name)
//        }
//
//        self.dataSource = UICollectionViewDiffableDataSource<Section, DJ>(collectionView: self.collectionView) {
//            (collectionView, indexPath, dj) -> UICollectionViewCell? in
//            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: dj)
//        }
    }

    func performQuery(with filter: String?) {
        let filtered = self.arr.filter { $0.name.hasPrefix(filter ?? "") }

        var snapshot = NSDiffableDataSourceSnapshot<Section, DJ>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filtered)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 3 : 2
            let spacing = CGFloat(10)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(32))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }
        return layout
    }
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        self.performQuery(with: text)
    }
}

class DJCollectionViewCell: UICollectionViewCell {
    
    weak var label: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.contentView.backgroundColor = .lightGray
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.black.cgColor
        
        let label = UILabel()
        label.textAlignment = .center
        label.frame = self.contentView.frame
        self.contentView.addSubview(label)
        self.label = label
    }
    
    func configure(text: String) {
        self.label?.text = text
    }
}
