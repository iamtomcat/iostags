import UIKit

public protocol TagProtocol {
  func getTags() -> [String]
  func getTagAtIndex(index: Int) -> String?
}

private let StartingWidth: CGFloat = 20.0

enum Tags: String {
  case Default = "Add Tag"
}

public class TagDelegate: TagProtocol {
  private var tags: [String] = [String]()
  private var tagDelegate: TagCollectionViewDelegate!
  private var tagDataSource: TagDataSource!
  var currentIndex: Int = 0
  
  convenience init(tags: [String]) {
    self.init()
    var temp = tags
    temp.append(Tags.Default.rawValue)
    self.tags = temp
  }

  func updateTags(tags: [String]) {
    if tags.count > 0 {
      self.tags = tags
    }
  }
  
  func setupDelegateAndDataSource(collectionView: UICollectionView, interface: TagsInterface) -> (delegate: TagCollectionViewDelegate, dataSource: TagDataSource) {
    tagDelegate = TagCollectionViewDelegate()
    tagDelegate.delegate = self
    tagDataSource = TagDataSource(collectionView: collectionView, data: interface)
    tagDataSource.delegate = self
    return (tagDelegate, tagDataSource)
  }

  public func getTags() -> [String] {
    return tags
  }

  public func getTagAtIndex(index: Int) -> String? {
    guard index > tags.count else {
      return nil
    }
    return tags[index]
  }
}


public class TagCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
  var delegate: TagDelegate!
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    func getStringSize(string: String, withFontSize size: CGFloat) -> CGSize {
      return string.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(size)])
    }

    let margin = CGFloat(10)
    let visibleCell = collectionView.visibleCells()[0] as? TagCell
    guard let sizeString = delegate.getTagAtIndex(indexPath.row) else {
      return CGSize(width: StartingWidth + margin, height: 20)
    }
    let size = getStringSize(sizeString, withFontSize: (visibleCell?.textField.font?.pointSize)!)
    return CGSize(width: size.width + margin, height: 20)
  }
}

class TagDataSource: NSObject {
  private var delegate: TagDelegate!
  private var collectionView: UICollectionView!
  private lazy var completionView: SuggestionView = {
    return SuggestionView()
  }()
  private var textFieldDelegate = TagsCollectionTextFieldDelegate()

  convenience init(collectionView: UICollectionView, data: TagsInterface) {
    self.init()
    self.collectionView = collectionView
  }

  func updateSuggestions(tag: TagContainer) {
    if self.completionView.numberOfItemsInSection(0) != tag.suggestedTypes.count {
      completionView.performBatchUpdates({ () -> Void in
        for idx in 0..<self.completionView.numberOfItemsInSection(0) {
          self.completionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)])
        }

        for idx in 0..<tag.suggestedTypes.count {
          self.completionView.insertItemsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)])
        }
      }) { (complete) -> Void in

      }
    }
  }
}

extension TagDataSource: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return delegate.tags.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tagCell", forIndexPath: indexPath)
    if let cell = cell as? TagCell {
      let text = delegate.getTagAtIndex(indexPath.row) ?? ""
      setupTagCell(cell, withTag: text)
    }
    return cell
  }

  private func setupTagCell(cell: TagCell, withTag tag: String) {
    cell.backgroundColor = UIColor.redColor()
    cell.textField.addTarget(self, action:#selector(TagDataSource.tagTextChanged), forControlEvents: .EditingChanged)
    cell.textField.delegate = textFieldDelegate
    cell.textField.inputAccessoryView = completionView
    cell.textField.text = tag
  }

  func tagTextChanged(textField: UITextField) {
    var resultFrame = CGRectZero
    if !textField.text!.isEmpty && textField.text != " " {
      let pos = textField.beginningOfDocument
      if let pos2 = textField.tokenizer.positionFromPosition(pos, toBoundary: .Line, inDirection: 0) {
        let range = textField.textRangeFromPosition(pos, toPosition: pos2)
        resultFrame = textField.firstRectForRange(range!)
      }
      let rectHold = textField.frame

      var width = CGFloat(20.0)
      if resultFrame.size.width+12.0 > StartingWidth {
        collectionView.collectionViewLayout.invalidateLayout()
        width = resultFrame.size.width+12.0
      }
      delegate.tags[delegate.currentIndex] = textField.text!
      textField.frame = CGRectMake(rectHold.origin.x, rectHold.origin.y, width, resultFrame.size.height)
      collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: delegate.currentIndex, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
    }
  }
}

