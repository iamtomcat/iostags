import UIKit

open class TagCell: UICollectionViewCell {
  @IBInspectable var cornerRadius = CGFloat(5.0)
  @IBInspectable var borderWidth = CGFloat(0.5)
  @IBInspectable var borderColor = UIColor.black.cgColor


  @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var trailingConstraint: NSLayoutConstraint!

  @IBOutlet weak var tagLabel: UILabel!

  fileprivate let newTagCommand = " "

  var insertNewTag: ((UICollectionViewCell) -> Void)?

  open var tagTitle: String = "" {
    didSet {
      tagLabel.text = tagTitle
    }
  }

  var cellWidth: CGFloat? {
    if let tagText = tagLabel.text, let font = tagLabel.font, !tagText.isEmpty {
      let width = CellWidth.widthOf(Text: tagText, withFont: font)

      let widthSum = width + leadingConstraint.constant + trailingConstraint.constant + 5

      return widthSum
    }
    return nil
  }

  open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    super.preferredLayoutAttributesFitting(layoutAttributes)
    if let cellWidth = cellWidth {
      layoutAttributes.bounds.size.width = cellWidth
    }
    tagLabel.setNeedsDisplay()

    return layoutAttributes
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layer.cornerRadius = cornerRadius
    layer.borderWidth = borderWidth
    layer.borderColor = borderColor
  }
}

extension TagCell: UITextFieldDelegate {
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.text == Tags.Default.rawValue {
      textField.text = ""
    }
  }

  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard !string.characters.isEmpty
      else { return true }

    if string.hasSuffix(newTagCommand) {
      insertNewTag?(self)
      return false
    }
    return true
  }
}
