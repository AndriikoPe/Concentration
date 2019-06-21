//
//  Card.swift
//  Concentration
//
//  Created by Пермяков Андрей on 24.07.2018.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//
//    
import Foundation

struct Card: Hashable {
    var hashValue: Int {
        return identifier
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    var isFaceUp = false
    var isMatched = false
    var identifier: Int
    
    private static var identifierFactory = 0
    private static func getUniqueIdentifier () -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init()  {
        self.identifier = Card.getUniqueIdentifier()
    }
}

