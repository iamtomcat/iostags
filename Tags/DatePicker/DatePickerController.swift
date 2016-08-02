//
//  DatePickerController.swift
//  Tags
//
//  Created by Tom Clark on 2016-06-26.
//  Copyright © 2016 Fluiddynamics. All rights reserved.
//

import UIKit

class DatePickerController: UIViewController {
  @IBOutlet private weak var picker: UIDatePicker!

  var textPass: (String -> Void)?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    commonInit()
  }

  private func commonInit() {
    modalPresentationStyle = .Custom
    transitioningDelegate = self
  }

  func handleTap(sender: UITapGestureRecognizer) {
    dismissViewControllerAnimated(true) {
      let text = FormatDate.format(self.picker.date)
      self.textPass?(text)
    }
  }
}

extension DatePickerController: UIViewControllerTransitioningDelegate {
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    return InputPresentationController(presentedViewController: presented, presentingViewController: presenting)
  }
}
