
import UIKit

class StoreItemContainerViewController: UIViewController, UISearchResultsUpdating {
    
    @IBOutlet var tableContainerView: UIView!
    @IBOutlet var collectionContainerView: UIView!
    
    let searchController = UISearchController()
    let storeItemController = StoreItemController()
    
    var tableViewDataSource: UITableViewDiffableDataSource<String, StoreItem>!
    var items = [StoreItem]()
    
    var filteredItemsSnapshot: NSDiffableDataSourceSnapshot<String, StoreItem> {
        var snapshot = NSDiffableDataSourceSnapshot<String, StoreItem>()
        
        for item in items{
            snapshot.appendItems([item])
        }
        return snapshot
    }

    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["Movies", "Music", "Apps", "Books"]
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 0.3)
    }
    
    func configureTableViewDataSource(_ tableView: UITableView) {
        tableViewDataSource = UITableViewDiffableDataSource<String, StoreItem>(
            tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemTableViewCell
                
                cell.titleLabel.text = item.name
                cell.detailLabel.text = item.artist
                cell.itemImageView?.image = UIImage(systemName: "photo")
                
                self.storeItemController.fetchImage(from: item.artworkURL) { (result) in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            cell.itemImageView.image = image
                        }
                    case .failure(let error):
                        print("Error fetching image: \(error)")
                    }
                }
                
                return cell
            })
    }
    
    private func createDataSourcer() {
        tableViewDataSource = UICollectionViewDiffableDataSource<String, StoreItem>(collectionView: collectionContainerView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: )
        })
    }
                
    @IBAction func switchContainerView(_ sender: UISegmentedControl) {
        tableContainerView.isHidden.toggle()
        collectionContainerView.isHidden.toggle()
    }
    
    @objc func fetchMatchingItems() {
        
        self.items = []
                
        let searchTerm = searchController.searchBar.text ?? ""
        let mediaType = queryOptions[searchController.searchBar.selectedScopeButtonIndex]
        
        if !searchTerm.isEmpty {
            
            // set up query dictionary
            let query = [
                "term": searchTerm,
                "media": mediaType,
                "lang": "en_us",
                "limit": "20"
            ]
            
            // use the item controller to fetch items
            storeItemController.fetchItems(matching: query) { (result) in
                switch result {
                case .success(let items):
                    // if successful, use the main queue to set self.items and reload the table view
                    DispatchQueue.main.async {
                        guard searchTerm == self.searchController.searchBar.text else {
                            return
                        }
                        
                        self.items = items
                        
                        // apply data source changes
                    }
                case .failure(let error):
                    // otherwise, print an error to the console
                    print(error)
                }
            }
        } else {
            // apply data source changes
        }
    }
    
}
