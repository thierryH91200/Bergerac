import AppKit

public protocol PopOverModalDelegate
{
    /// Called when a value has been selected inside the outline.
    func changeView(_ name: String)
}

final class PopOverModalViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    var collectionViewItem: KSRetailCollectionViewItem!
    var contents = [[String: String ]]()
    
    public var delegate: PopOverModalDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        
        self.collectionViewItem = KSRetailCollectionViewItem(nibName: NSNib.Name( "KSRetailCollectionViewItem"), bundle: nil)
        
        self.contents = [
            ["itemTitle": "Bank",        "itemImage": "icons8-museum-80"],
            ["itemTitle": "Safe",        "itemImage": "icons8-money-box-80"],
            ["itemTitle": "Bank",        "itemImage": "icons8-money-100"],
            ["itemTitle": "Safe",        "itemImage": "icons8-expensive-100"],
            ["itemTitle": "Safe",        "itemImage": "icons8-purse-100"],
            ["itemTitle": "Wallet",      "itemImage": "icons8-wallet-80"],
            ["itemTitle": "Safe",        "itemImage": "icons8-safe-100"],
            ["itemTitle": "Credit Card", "itemImage": "discount"],
            ["itemTitle": "PayPal",      "itemImage": "icons8-paypal-100"]]

            // MARK: symbols SF
//        self.contents = [
//            ["itemTitle" : "person",      "itemImage" : "person"],
//            ["itemTitle" : "Bank Note",   "itemImage" : "banknote"],
//            ["itemTitle" : "Credit Card", "itemImage" : "creditcard"],
//            ["itemTitle" : "wallet pass", "itemImage" : "wallet.pass"],
//            ["itemTitle" : "Credit Card", "itemImage" : "creditcard.and.123"],
//            ["itemTitle" : "Credit Card", "itemImage" : "creditcard"],
//            ["itemTitle" : "Credit Card", "itemImage" : "creditcard.and.123"],
//            ["itemTitle" : "Credit Card", "itemImage" : "creditcard"],
//            ["itemTitle" : "Credit Card", "itemImage" : "creditcard"]]
        
        let nib = NSNib(nibNamed: NSNib.Name( "KSRetailCollectionViewItem"), bundle: nil)
        collectionView.register(KSRetailCollectionViewItem.self, forItemWithIdentifier: .collectionViewItem)
        self.collectionView.register(nib, forItemWithIdentifier: .collectionViewItem)
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    fileprivate func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 100.0, height: 100.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        collectionView.collectionViewLayout = flowLayout
        collectionView.layer?.backgroundColor = NSColor.black.cgColor
    }
}

    // MARK: - NSCollectionViewDataSource
extension PopOverModalViewController: NSCollectionViewDataSource
{
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contents.count // <- This depends on the data being displayed
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let collectionObject = self.contents[indexPath.item]
        let item = self.collectionView.makeItem(withIdentifier: .collectionViewItem, for: indexPath)
        item.representedObject = collectionObject
        return item
    }
    
}

    // MARK: - NSCollectionViewDelegate
extension PopOverModalViewController: NSCollectionViewDelegate
{
    func collectionView (_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>)
    {
        guard let indexPath = indexPaths.first else { return }
        guard let item = collectionView.item(at: indexPath) else { return }
        
        let rep = (item as! KSRetailCollectionViewItem).representedObject as? [String: String]
        let name = rep?["itemImage"]!
        delegate?.changeView( name!)
    }
    
}

