import UIKit
import SnapKit

extension MarketDiscoveryFilterHeaderView {
    struct ViewItem {
        let icon: String
        let title: String
        let description: String?

        init(icon: String, title: String) {
            self.icon = icon
            self.title = title
            description = nil
        }

        init(icon: String, title: String, description: String) {
            self.icon = icon
            self.title = title
            self.description = description
        }
    }
}

class MarketDiscoveryFilterHeaderView: UIView {
    public static var headerHeight: CGFloat = 118

    private var filters = [MarketDiscoveryFilterHeaderView.ViewItem]()

    private let collectionView: UICollectionView
    private var loaded = false
    private let expandable: Bool //todo remove expandability after new discovery UI implementation

    var onSelect: ((Int?) -> ())?

    init(expandable: Bool) {
        self.expandable = expandable

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: .zero)

        addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: .margin12, left: .margin16, bottom: .margin12, right: .margin16)
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.registerCell(forClass: FilterCard.self)

        loaded = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

}

extension MarketDiscoveryFilterHeaderView {

    func set(filters: [MarketDiscoveryFilterHeaderView.ViewItem]) {
        self.filters = filters

        if loaded {
            collectionView.reloadData()
        }
    }

}

extension MarketDiscoveryFilterHeaderView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FilterCard.self), for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? FilterCard {
            cell.bind(item: filters[indexPath.item], expandable: expandable)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        FilterCard.size(item: filters[indexPath.item], selected: collectionView.indexPathsForSelectedItems?.first == indexPath, expandable: expandable)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        .margin12
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard collectionView.indexPathsForSelectedItems?.first == indexPath else {
            return true
        }

        UIView.animate(withDuration: .themeAnimationDuration) {
            collectionView.performBatchUpdates {
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        }

        handleSelect()

        return false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: .themeAnimationDuration) {
            collectionView.performBatchUpdates {
                collectionView.collectionViewLayout.invalidateLayout()

                // explicitly set content size in order to fix behavior of scrollToItem
                collectionView.contentSize = collectionView.collectionViewLayout.collectionViewContentSize

                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }

        handleSelect()
    }

    private func handleSelect() {
        onSelect?(collectionView.indexPathsForSelectedItems?.first?.item)
    }

}

extension MarketDiscoveryFilterHeaderView {

    func setSelected(index: Int?) {
        guard collectionView.indexPathsForSelectedItems?.first?.item != index else {
            return
        }

        let indexPath = index.map { IndexPath(item: $0, section: 0) }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        collectionView.performBatchUpdates(nil)
    }

}
