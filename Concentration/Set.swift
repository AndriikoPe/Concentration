//
//  Set.swift
//  GoodSet
//
//  Created by Пермяков Андрей on 12/26/18.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//

import Foundation

struct Set {
    
    private(set) var cardsInGame = [SetCard]()
    private(set) var selectedCards = [Int:SetCard]()
    private(set) var deck = [SetCard]()
    var flipCounter = 0
    var scoreCounter = 0
    
    mutating func deal(cards arr: [Int], replacingOldCards: Bool = false) {
        assert(deck.count > 0, "Trying to deal from an empty deck")
        if replacingOldCards {
            for index in arr.indices {
                cardsInGame[arr[index]] = deck.popLast()!
            }
            selectedCards = [:]
        } else {
            for _ in arr.indices {
                cardsInGame.append(deck.popLast()!)
            }
        }
    }
    
    private mutating func removeCards(at indexes: [Int]) {
        for index in indexes {
            cardsInGame.remove(at: index)
        }
    }
    
    mutating func selectCard (with title: SetCard, at index: Int) {
        if selectedCards.count < 3 {
            selectedCards[index] = selectedCards.values.contains(title) ? nil : title
        } else if !areSelectedCardsSet() { //3 cards, not set
            selectedCards = [:]
            selectedCards[index] = title
        } else {                           //3 cards, set => removing cards
            removeCards(at: Array(selectedCards.keys))
            selectedCards = [:]
        }
    }
    
    mutating func add3MoreCards() {
        if areSelectedCardsSet() {
            deal(cards: Array(selectedCards.keys), replacingOldCards: true)
        } else if deck.count > 0 {
            deal(cards: [1, 2, 3])
        }
    }
    
    init() {
        for indexOfSymbol in 1...3 {
            for indexOfNumber in 1...3 {
                for indexOfColor in 1...3 {
                    for indexOfShading in 1...3 {
                        deck.append(SetCard(indexOfSymbol, indexOfNumber, indexOfColor, indexOfShading))
                    }
                }
            }
        }
        shuffleCards()
        let firstDeal = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
        deal(cards: firstDeal)
    }
    
    mutating func shuffleCards() {
        let randomTimes = 50.arc4random + 30
        for _ in 1...randomTimes {
            let randomIndex_1 = 81.arc4random
            let randomIndex_2 = 81.arc4random
            let card = deck[randomIndex_1]
            deck[randomIndex_1] = deck[randomIndex_2]
            deck[randomIndex_2] = card
        }
    }
    
    func areSelectedCardsSet() -> Bool{
        return areCardsSet(Array(selectedCards.values))
    }
    
    func isThereASetOnTheBoard() -> (found: Bool, setArray: [Int]) { // cheat button extra credit
        for outerI in 0 ..< (cardsInGame.count - 1) {
            for innerI in (outerI + 1) ..< cardsInGame.count {
                var sameOrDiff = [Int]()
                let symb1 = cardsInGame[outerI].symbolShape,
                symb2 = cardsInGame[innerI].symbolShape,
                num1 = cardsInGame[innerI].symbolNumber,
                num2 = cardsInGame[outerI].symbolNumber,
                color1 = cardsInGame[innerI].symbolColor,
                color2 = cardsInGame[outerI].symbolColor,
                style1 = cardsInGame[innerI].symbolShading,
                style2 = cardsInGame[outerI].symbolShading
                
                sameOrDiff.append(findTheThird(in: [symb1, symb2]))
                sameOrDiff.append(findTheThird(in: [num1, num2]))
                sameOrDiff.append(findTheThird(in: [color1, color2]))
                sameOrDiff.append(findTheThird(in: [style1, style2]))
                let card = SetCard(sameOrDiff[0], sameOrDiff[1], sameOrDiff[2], sameOrDiff[3])
                if cardsInGame.contains(card) {
                    var thirdIndex = 0
                    for index in cardsInGame.indices {
                        if cardsInGame[index] == card {
                            thirdIndex = index
                        }
                    }
                    return (true, [outerI, innerI, thirdIndex])
                }
            }
        }
        return (false, [])
    }
    
    private func findTheThird(in arr: [Int]) -> Int {
        if arr[0] == arr[1] {
            return arr[0]
        }
        for number in 1...3 {
            if number != arr[0] && number != arr[1] {
                return number
            }
        }
        return 0
    }
    
    private func areCardsSet(_ arr: [SetCard]) -> Bool {
        if arr.count == 3 {
            var arrayOfSymbols = [Int](), arrayOfNumbers = [Int](), arrayOfColors = [Int](), arrayOfShades = [Int]()
            for index in arr.indices {
                arrayOfSymbols.append(arr[index].symbolShape)
                arrayOfColors.append(arr[index].symbolColor)
                arrayOfNumbers.append(arr[index].symbolNumber)
                arrayOfShades.append(arr[index].symbolShading)
            }
            let symbolsSet = arrayOfSymbols.areAll3Same != arrayOfSymbols.areAll3Different
            let colorsSet = arrayOfColors.areAll3Same != arrayOfColors.areAll3Different
            let numbersSet = arrayOfNumbers.areAll3Same != arrayOfNumbers.areAll3Different
            let shadesSet = arrayOfShades.areAll3Same != arrayOfShades.areAll3Different
            return symbolsSet && colorsSet && numbersSet && shadesSet
        }
        return false
    }
    
    mutating func incFlilpCounter() -> String {
        flipCounter += 1
        return "Flips: \(flipCounter)"
    }
    
    mutating func changeScoreCount(to number: Int) -> String {
        scoreCounter += number
        return "Score: \(scoreCounter)"
    }
}

extension Array where Element: Equatable {
    var areAll3Same: Bool {
        return self[0] == self[1] && self[1] == self[2]
    }
    var areAll3Different: Bool {
        return self[0] != self[1] && self[1] != self[2] && self[2] != self[0]
    }
}
