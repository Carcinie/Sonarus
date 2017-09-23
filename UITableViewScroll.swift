//
//  UITableViewScroll.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 5/11/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation
import UIKit

extension UITableView{
    func scrollToBottom(){
        
        if (numberOfRows(inSection: 0) > 0){
            let index = IndexPath(row: self.numberOfRows(inSection: 0) - 1, section: 0)//last cell
            self.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }
}
