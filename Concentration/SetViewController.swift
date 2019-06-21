//
//  ViewController.swift
//  GoodSet
//
//  Created by Пермяков Андрей on 12/26/18.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    lazy var animator = UIDynamicAnimator(referenceView: self.view)
    var UIEnterAnimated = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !UIEnterAnimated {
            CardsView.transform = CGAffineTransform(translationX: 0, y: 300)
            UIView.animate(withDuration: 1.0, delay: 0, animations: {
                self.CardsView.transform = CGAffineTransform(translationX: 0, y: 0)
            } )
            UIEnterAnimated = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in game.cardsInGame.indices {
            CardsView.addCard(withImage: game.cardsInGame[index], at: index, caseOfAdding: .addingNewCards)
        }
        ButtonsView.changeFlips(to: "Flips: 0")
        ButtonsView.changeScore(to: "Score: 0")
    }
    
    @IBOutlet weak var CardsView: SetView!
    @IBOutlet weak var ButtonsView: SetButtonsView!
    
    @objc func cardTouched(_ sender: UIButton!) {
        let index = sender.tag
        let title = game.cardsInGame[index]
        ButtonsView.changeFlips(to: game.incFlilpCounter())
        game.selectCard(with: title, at: index)
        if game.areSelectedCardsSet() {
            let selectedCards = Array(game.selectedCards.keys)
            for tag in game.selectedCards.keys {
                let viewOfButton = CardsView.viewWithTag(tag)!
                if let button = viewOfButton as? UIButton {
                    UIView.animate(withDuration: 0.4, animations: {
                        let height = self.ButtonsView.viewWithTag(2)!.bounds.height
                        let width = self.ButtonsView.viewWithTag(2)!.bounds.width
                        button.bounds = CGRect(x: button.bounds.origin.x, y: button.bounds.origin.y, width: width, height: height)
                    }, completion: { (success) in
                        let pile = self.ButtonsView.viewWithTag(2)!
                        let pilePoint = CGPoint(x: pile.frame.origin.x + pile.bounds.width / 2 + 16, y: self.CardsView.bounds.height + pile.frame.origin.y + pile.bounds.height)
                        let snapBehavior = UISnapBehavior(item: button, snapTo: pilePoint)
                        self.animator.addBehavior(snapBehavior)
                        UIView.animate(withDuration: 0.6, animations: {
                            button.alpha = 0.3
                        })
                    })
                }
            }
            let key = selectedCards.last!
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (timer) in
                let flippingCard = self.CardsView.viewWithTag(key)! as! UIButton
                flippingCard.alpha = 1
                UIView.transition(with: flippingCard, duration: 1, options: .transitionFlipFromLeft, animations: {
                }, completion: { _ in
                    self.add3MoreCards()
                    self.animator.removeAllBehaviors()
                })
                }
            if game.deck.count <= 0 {
               CardsView.removeCards(for: selectedCards)
            }
        } else if game.selectedCards.count == 3 {
            for tag in game.selectedCards.keys {
                let button = CardsView.viewWithTag(tag)!
                let buttonBounds = button.bounds
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseIn, animations: {
                    button.bounds = CGRect(x: buttonBounds.origin.x - 5, y: buttonBounds.origin.y - 5, width: buttonBounds.size.width + 5, height: buttonBounds.size.height + 5)
                }, completion: {
                    if $0 {
                        button.bounds = buttonBounds
                    }
                })
            }
        }
        updateViewFromModel()
    }
    
    /*
     add3MoreCards animation:
     game.add3more, then set their alpha = 0, then move them to "deck", then set their alpha = 1, then let thenm fly to original places -_-
     */
    @objc func add3MoreCards() {
        if game.deck.count > 0 {
            if game.areSelectedCardsSet() {
                let indexes = Array(game.selectedCards.keys)
                game.add3MoreCards()
                for key in indexes {
                    CardsView.addCard(withImage: game.cardsInGame[key], at: key, caseOfAdding: .replacingOldCard)
                }
                ButtonsView.changeScore(to: game.changeScoreCount(to: +3))
                CardsView.selectedCards = Array(game.selectedCards.keys)
                CardsView.redrawView(withHiddenViews: indexes)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    var cardsOriginalPositions = [CGPoint]()
                    for key in indexes {
                        let card = self.CardsView.viewWithTag(key)! as! UIButton
                        card.alpha = 0
                        cardsOriginalPositions.append(card.frame.origin)
                        let deckFrame = self.ButtonsView.viewWithTag(1)!.frame
                        card.frame.origin = CGPoint(x: deckFrame.origin.x + self.ButtonsView.bounds.width / 2, y: deckFrame.origin.y + self.CardsView.bounds.height)
                    }
                    let firstCard = self.CardsView.viewWithTag(indexes[0])!
                    firstCard.alpha = 1
                    UIView.animate(withDuration: 0.6, animations: {
                        firstCard.frame.origin = cardsOriginalPositions[0]
                    }, completion: { (a) in
                        let secondCard = self.CardsView.viewWithTag(indexes[1])!
                        secondCard.alpha = 1
                        UIView.animate(withDuration: 0.6, animations: {
                            secondCard.frame.origin = cardsOriginalPositions[1]
                        }, completion: { (b) in
                            let thirdCard = self.CardsView.viewWithTag(indexes[2])!
                            thirdCard.alpha = 1
                            UIView.animate(withDuration: 0.6, animations: {
                                thirdCard.frame.origin = cardsOriginalPositions[2]
                            }, completion: nil)
                        })
                    })
                }
            } else {
                if game.isThereASetOnTheBoard().0 {
                    ButtonsView.changeScore(to: game.changeScoreCount(to: -2))
                } else {
                    ButtonsView.changeScore(to: game.changeScoreCount(to: +2))
                }
                var count = game.cardsInGame.count
                game.add3MoreCards()
                var indexes = [Int]()
                for _ in 0...2 {
                    CardsView.addCard(withImage: game.cardsInGame[count], at: count, caseOfAdding: .addingNewCards)
                    indexes.append(count)
                    count += 1
                }
                CardsView.redrawView(withHiddenViews: indexes)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    var cardsOriginalPositions = [CGPoint]()
                    for key in indexes {
                        let card = self.CardsView.viewWithTag(key)! as! UIButton
                        card.alpha = 0
                        cardsOriginalPositions.append(card.frame.origin)
                        let deckFrame = self.ButtonsView.viewWithTag(1)!.frame
                        card.frame.origin = CGPoint(x: deckFrame.origin.x + self.ButtonsView.bounds.width / 2, y: deckFrame.origin.y + self.CardsView.bounds.height)
                    }
                    let firstCard = self.CardsView.viewWithTag(indexes[0])!
                    firstCard.alpha = 1
                    UIView.animate(withDuration: 0.6, animations: {
                        firstCard.frame.origin = cardsOriginalPositions[0]
                    }, completion: { (a) in
                        let secondCard = self.CardsView.viewWithTag(indexes[1])!
                        secondCard.alpha = 1
                        UIView.animate(withDuration: 0.6, animations: {
                            secondCard.frame.origin = cardsOriginalPositions[1]
                        }, completion: { (b) in
                            let thirdCard = self.CardsView.viewWithTag(indexes[2])!
                            thirdCard.alpha = 1
                            UIView.animate(withDuration: 0.6, animations: {
                                thirdCard.frame.origin = cardsOriginalPositions[2]
                            }, completion: nil)
                        })
                    })
                }
            }
        }
    }
    
    func updateViewFromModel() {
        for card in game.cardsInGame.indices {
            if game.selectedCards.keys.contains(card) {
                CardsView.viewWithTag(card)!.layer.borderWidth = 5.0
                CardsView.viewWithTag(card)!.layer.borderColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
            } else {
                CardsView.viewWithTag(card)!.layer.borderWidth = 0.0
            }
        }
    }
    
    @objc func newGameButton() {
        game = Set()
        ButtonsView.changeFlips(to: "Flips: 0")
        ButtonsView.changeScore(to: "Score: 0")
        CardsView.arrayOfCards.removeAll()
        for index in game.cardsInGame.indices {
            CardsView.addCard(withImage: game.cardsInGame[index], at: index, caseOfAdding: .addingNewCards)
        }
        CardsView.redrawView()
    }
    
    @objc func cheatButton() {
        let (isSetFound, setArray) = game.isThereASetOnTheBoard()
        if isSetFound {
            for card in game.cardsInGame.indices {
                if setArray.contains(card) {
                    CardsView.viewWithTag(card)!.layer.borderWidth = 5.0
                    CardsView.viewWithTag(card)!.layer.borderColor = #colorLiteral(red: 1, green: 0.3111287901, blue: 0.2895851275, alpha: 1)
                }
            }
        }
    }
    
    lazy var game = Set()
}

extension CGFloat {
    var arc4random : CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}
