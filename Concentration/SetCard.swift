//
//  SetCard.swift
//  GoodSet
//
//  Created by Пермяков Андрей on 12/26/18.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//

import Foundation

struct SetCard: Equatable {
    let symbolShape: Int
    let symbolNumber: Int
    let symbolColor: Int
    let symbolShading: Int
    
    static func == (lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.symbolShape == rhs.symbolShape &&
            lhs.symbolColor == rhs.symbolColor &&
            lhs.symbolShading == rhs.symbolShading &&
            lhs.symbolNumber == rhs.symbolNumber
    }
    
    init(_ symbol: Int,_ number: Int,_ symbColor: Int,_ shading: Int) {
        symbolShape = symbol
        symbolNumber = number
        symbolColor = symbColor
        symbolShading = shading
    }
}
