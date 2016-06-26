//
//  CellWidth.swift
//  Tags
//
//  Created by Tom Clark on 2016-06-21.
//  Copyright © 2016 Fluiddynamics. All rights reserved.
//

import Foundation

struct CellWidth {
  static func widthOf(Text text: String, withFont font: UIFont) -> CGFloat {
    return text.sizeWithAttributes([NSFontAttributeName: font]).width + 20
  }
}