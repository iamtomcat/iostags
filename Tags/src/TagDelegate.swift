import UIKit

public protocol TagProtocol {
  func getTags() -> [String]
  func getTagAtIndex(index: Int) -> String?
}

enum Tags: String {
  case Default = "Add Tag"
}

public class TagDelegate: NSObject {
  private var tags = [String]()
  private weak var collectionView: UICollectionView?

  private lazy var parser: TagParser = TagParser(tags: self.tagDataSource)
  private lazy var suggestionView: SuggestionView = SuggestionView()

  private lazy var collectionDataSource: CollectionArrayDataSource<String, TagCell> = {
    let ds = CollectionArrayDataSource<String, TagCell>(anArray: [self.tags], withCellIdentifier: String(TagCell), andCustomizeClosure: self.customizeCell)
    return ds
  }()

  public convenience init(collectionView: UICollectionView, tags: [String]) {
    self.init()
    self.tags = tags
    collectionView.dataSource = collectionDataSource
    self.collectionView = collectionView
  }

  public var tagDataSource: TagsDataSource!

  private func getSuggestions(item: String) {
    let items = parser.parse(item).map { tag -> String in
      if let raw = tag.type?.rawValue where tag.isCommand {
        return raw
      }
      return tag.title
    }

    suggestionView.tags = items
  }

  func customizeCell(cell: TagCell, item: String, path: NSIndexPath) {
    cell.tagTitle = item
    cell.insertNewTag = { cell in

      guard let currentIndexPath = self.collectionView?.indexPathForCell(cell)
        else { return }

      self.tags.append("")
      self.collectionDataSource.updateData([self.tags])

      let newIndexPath = NSIndexPath(forRow: currentIndexPath.row+1, inSection: currentIndexPath.section)
      self.collectionView?.insertItemsAtIndexPaths([newIndexPath])

      if let newCell = self.collectionView?.cellForItemAtIndexPath(newIndexPath) as? TagCell {
        newCell.textField.becomeFirstResponder()
      }
    }
    cell.textField.addTarget(self, action: #selector(TagDelegate.tagTextChanged), forControlEvents: .EditingChanged)
    cell.textField.inputAccessoryView = suggestionView
  }

  @objc
  private func tagTextChanged(textField: UITextField) {
    if let tagText = textField.text {
      getSuggestions(tagText)
    }
    collectionView?.collectionViewLayout.invalidateLayout()
  }
}

extension TagDelegate: UICollectionViewDelegateFlowLayout {
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TagCell,
    tagText = cell.textField.text, font = cell.textField.font
      else { return CGSize(width: 20, height: collectionView.bounds.height) }

    let width = CellWidth.widthOf(Text: tagText, withFont: font)
    return CGSize(width: width, height: collectionView.bounds.height)
  }
}
