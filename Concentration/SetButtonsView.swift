//
//  SetButtonsView.swift
//  Set
//
//  Created by Пермяков Андрей on 11/12/18.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//

import UIKit

class SetButtonsView: UIView {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    private func createAnAdd3MoreCardsButton () {
        let button = UIButton(frame: CGRect(x: CGPoint.zero.x, y: CGPoint.zero.y, width: bounds.width, height: bounds.height / 3))
        button.addTarget(SetViewController(), action: #selector(SetViewController.add3MoreCards), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        button.setAttributedTitle(centeredAttributedString("Add 3 more cards", fontSize: 36), for: UIControl.State.normal)
        button.tag = 1
        self.addSubview(button)
    }
    
    var scoreLabel = UILabel()
    var flipCountLabel = UILabel()
    
    func changeScore (to string: String) {
        var fontSize: CGFloat
        if string.count == 8 {
            fontSize = 25
        } else if string.count == 9{
            fontSize = 20
        } else {
            fontSize = 16
        }
        scoreLabel.attributedText = centeredAttributedString(string, fontSize: fontSize)
    }
    
    func changeFlips (to string: String) {
        var fontSize: CGFloat
        if string.count == 8 {
            fontSize = 25
        } else if string.count == 9{
            fontSize = 20
        } else {
            fontSize = 16
        }
        flipCountLabel.attributedText = centeredAttributedString(string, fontSize: fontSize)
    }
    
    private func createSecondFloor () {
        let yPositionOfTheSecondFloor = bounds.height / 3
        let xPositionOfTheScoreLabel = CGPoint(x: 0, y: yPositionOfTheSecondFloor)
        let xPositionOfTheCheatButton = CGPoint(x: bounds.width / 3, y: yPositionOfTheSecondFloor)
        let xPositionOfTheFlipCountLabel = CGPoint(x: bounds.width * 2 / 3, y: yPositionOfTheSecondFloor)
        
        let cheatButton = UIButton(frame: CGRect(origin: xPositionOfTheCheatButton, size: CGSize(width: bounds.width / 3, height: bounds.height / 3)))
        cheatButton.setAttributedTitle(centeredAttributedString("Cheat", fontSize: 36), for: UIControl.State.normal)
        cheatButton.addTarget(SetViewController(), action: #selector(SetViewController.cheatButton), for: .touchUpInside)
        cheatButton.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        self.addSubview(cheatButton)
        
        scoreLabel.frame = CGRect(origin: xPositionOfTheScoreLabel, size: CGSize(width: bounds.width / 3, height: bounds.height / 3))
        scoreLabel.tag = 2 //pile
        flipCountLabel.frame = CGRect(origin: xPositionOfTheFlipCountLabel, size: CGSize(width: bounds.width / 3, height: bounds.height / 3))
        self.addSubview(scoreLabel)
        self.addSubview(flipCountLabel)
    }
    
    override func draw(_ rect: CGRect) {
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.createAnAdd3MoreCardsButton()
        self.createSecondFloor()
        self.createANewGameButton()
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        if #available(iOS 11.0, *) {
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle, .font: font])
    }
    
    private func createANewGameButton () {
        let button = UIButton(frame: CGRect(x: CGPoint.zero.x, y: bounds.height / 3 * 2, width: bounds.width, height: bounds.height / 3))
        button.addTarget(SetViewController(), action: #selector(SetViewController.newGameButton), for: .touchUpInside)
        let fontSize = min(bounds.height * 0.2, bounds.width * 0.2)
        button.setAttributedTitle(centeredAttributedString("New Game", fontSize: fontSize), for: UIControl.State.normal)
        button.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        self.addSubview(button)
    }
}
