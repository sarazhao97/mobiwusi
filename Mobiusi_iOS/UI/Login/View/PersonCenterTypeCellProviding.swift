//
//  PersonCenterTypeCellProviding.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/31.
//

import Foundation
protocol PersonCenterTypeCellProviding {
    var cellHeight: CGFloat { get }
    var didSelectedCell: ((UITableViewCell) -> Void)? { get set }
}
