//
//  ViewController.swift
//  Concentration
//
//  Created by Пермяков Андрей on 23.07.2018.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    var numberOfPairsOfCards : Int {
        return (cardButtons.count + 1) / 2
    }
    private(set) var flipsCount = 0 {
        didSet {
            flipCountLabel.text = "Flips: \(flipsCount)"
        }
    }
    
    @IBAction private func startNewGame() {
        emoji = [:]
        game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
        randomTheme = emojiChoicesThemes[emojiChoicesThemes.count.arc4random]
        flipsCount = 0
        changeScore(to: 0)
    }
    
    func changeScore (to score:Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private var cardButtons: [UIButton]!
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBAction private func touchCard(_ sender: UIButton) {
        let cardNumber = cardButtons.firstIndex(of: sender)!
        game.chooseCard(at: cardNumber)
        flipsCount = game.flipsCount
        changeScore(to: game.score)
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        if cardButtons != nil {
            for index in cardButtons.indices {
                let button = cardButtons[index]
                let card = game.cards[index]
                if card.isFaceUp {
                    button.setTitle(emoji(for: card), for: UIControl.State.normal)
                    button.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                } else {
                    button.setTitle("", for: UIControl.State.normal)
                    button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 0) : #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                }
            }
        }
    }
    
    private var emojiChoicesThemes: [String] = [
        "🎃👻😱😈🧙🏾‍♀️☠️",
        "🏀🏈🎾⚽️🏐⚾️",
        "😀😅😘😎😱🤢",
        "🐶🐒🦉🦖🐄🐿",
        "🍏🍑🌶🍆🍰🍕",
        "🚗🚔✈️🚁🏍🚲",
    ]
    var theme: String? {
        didSet {
            randomTheme = theme ?? ""
            emoji = [:]
            updateViewFromModel()
        }
    }
    /*lazy */private var randomTheme = "🚗🚔✈️🚁🏍🚲" //emojiChoicesThemes[emojiChoicesThemes.count.arc4random]
    private var emoji = [Card:String]()
    func emoji (for card: Card) -> String {
        if randomTheme.count > 0, emoji[card] == nil {
            let randomStringIndex = randomTheme.index(randomTheme.startIndex, offsetBy: randomTheme.count.arc4random)
            emoji[card] = String(randomTheme.remove(at: randomStringIndex))
        }
        return emoji[card] ?? "?"
    }
}
extension Int {
    var arc4random : Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}



