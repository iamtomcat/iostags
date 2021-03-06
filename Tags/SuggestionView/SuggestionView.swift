//
//  SuggestionView.swift
//  Tags
//
//  Created by Tom Clark on 2015-10-16.
//  Copyright © 2016 Fluiddynamics. All rights reserved.
//

import UIKit

open class SuggestionView: UICollectionView {
  private lazy var suggestionDataSource: CollectionArrayDataSource<Tag, CompletionCell> = {
    return CollectionArrayDataSource<Tag, CompletionCell>(anArray: [self.suggestions],
                                                                             withCellIdentifier: String(describing: CompletionCell.self),
                                                                             andCustomizeClosure: self.setupSuggestionCell)
  }()

  open var suggestions: [Tag] = [] {
    didSet {
      suggestionDataSource.updateData([suggestions])
      self.reloadData()
    }
  }
  open var setSuggestion: ((Tag) -> Void)?

  convenience public init(suggestion: ((Tag) -> Void)?) {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.estimatedItemSize = CGSize(width: 100, height: 38)
    layout.minimumInteritemSpacing = 10

    let width = UIScreen.main.bounds.width
    let frame = CGRect(x: 0, y: 0, width: width, height: 40)
    self.init(frame: frame, collectionViewLayout: layout)

    delegate = self
    dataSource = suggestionDataSource
    registerNibWithTitle(String(describing: CompletionCell.self), withBundle: Bundle(for: type(of: self)))
    self.setSuggestion = suggestion
  }

  convenience public init() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.estimatedItemSize = CGSize(width: 100, height: 38)
    layout.minimumInteritemSpacing = 10

    let width = UIScreen.main.bounds.width
    let frame = CGRect(x: 0, y: 0, width: width, height: 40)
    self.init(frame: frame, collectionViewLayout: layout)

    delegate = self
    dataSource = suggestionDataSource
    registerNibWithTitle(String(describing: CompletionCell.self), withBundle: Bundle(for: type(of: self)))
  }

  private func setupSuggestionCell(_ cell: CompletionCell, item: Tag, path: IndexPath) {
    cell.title = suggestions[path.row].suggestionTitle
    cell.cellTag = item
    cell.backgroundColor = .red
  }
}

extension SuggestionView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? CompletionCell
      else { return }
    setSuggestion?(cell.cellTag)
  }
}
