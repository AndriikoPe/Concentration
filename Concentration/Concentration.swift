//
//  Concentration.swift
//  Concentration
//
//  Created by Пермяков Андрей on 24.07.2018.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//

import Foundation

struct Concentration {
    private(set) var cards = [Card]()
    private var indexOfOneAndOnlyCardFaceUp : Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.theOneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    private(set) var score = 0
    var cardAlreadySeen = [Int: Int]()
    private(set) var flipsCount =  0
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index): chosen card is not in the cards")
        
        if !cards[index].isMatched {
            flipsCount += 1
            func checkIfWasAlreadyShown(card id: Int) -> Bool {
                for cardId in cardAlreadySeen.values {
                    if id == cardId {
                        return true
                    }
                }
                return false
            }
            if let matchIndex = indexOfOneAndOnlyCardFaceUp, matchIndex != index {
                if cards[matchIndex].identifier == cards[index].identifier {
                    cards[index].isMatched = true
                    cards[matchIndex].isMatched = true
                    score += 2
                } else {
                    if cardAlreadySeen[matchIndex] != nil {
                        score -= 1
                    }
                    if cardAlreadySeen[index] != nil {
                        score -= 1
                    }
                    if checkIfWasAlreadyShown(card: cards[matchIndex].identifier) {
                        score -= 1
                    }
                }
                cardAlreadySeen[index] = cards[index].identifier
                cardAlreadySeen[matchIndex] = cards[matchIndex].identifier
                cards[index].isFaceUp = true
            } else {
                indexOfOneAndOnlyCardFaceUp = index
            }
        }
    }
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0 , "Concentration.init(\(numberOfPairsOfCards): you must have at least one pair of cards")
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        var newCards = cards
        for indexInCards in cards.indices {
            let randomNumber = newCards.count.arc4random
            cards[indexInCards] = newCards.remove(at: randomNumber)
        }
    }
}


extension Collection {
    var theOneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
