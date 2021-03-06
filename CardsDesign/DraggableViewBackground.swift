//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

class DraggableViewBackground: UIView, DraggableViewDelegate {
    var exampleCardLabels: [String]!
    var allCards: [DraggableView]!

    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 386
    let CARD_WIDTH: CGFloat = 270

    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    var undoButton: UIButton!
    var beenthereButton: UIButton!
    
    var fituLabel: UILabel!
    var restaurants = [RestaurantModel]()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.setupView()
        exampleCardLabels = ["first", "second", "third", "fourth", "last"]
        allCards = []
        loadedCards = []
        cardsLoadedIndex = 0
    }

    func setupView() -> Void {
        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        
        fituLabel = UILabel(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 5, y: self.frame.size.height/2 + CARD_HEIGHT/2 - 445, width: 200, height: 20))
        fituLabel.text = "Restaurants to fit you"
        fituLabel.textAlignment = NSTextAlignment.left
        fituLabel.textColor = UIColor.lightGray
        fituLabel.font = fituLabel.font.withSize(13)
        
        undoButton = UIButton(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 20, y: self.frame.size.height/2 + CARD_HEIGHT/2 - 9, width: 40, height: 40))
        undoButton.setImage(UIImage(named: "undo"), for: UIControlState())
        undoButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        xButton = UIButton(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2 + 60, y: self.frame.size.height/2 + CARD_HEIGHT/2 - 24, width: 80, height: 80))
        xButton.setImage(UIImage(named: "xButton"), for: UIControlState())
        xButton.addTarget(self, action: #selector(DraggableViewBackground.swipeLeft), for: UIControlEvents.touchUpInside)

        checkButton = UIButton(frame: CGRect(x: self.frame.size.width/2 + CARD_WIDTH/2 - 150, y: self.frame.size.height/2 + CARD_HEIGHT/2 - 24, width: 80, height: 80))
        checkButton.setImage(UIImage(named: "checkButton"), for: UIControlState())
        checkButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        beenthereButton = UIButton(frame: CGRect(x: self.frame.size.width/2 + CARD_WIDTH/2 - 80, y: self.frame.size.height/2 + CARD_HEIGHT/2 - 9 , width: 50, height: 40))
        beenthereButton.setImage(UIImage(named: "beenthere"), for: UIControlState())
        beenthereButton.addTarget(self, action: #selector(DraggableViewBackground.swipeRight), for: UIControlEvents.touchUpInside)
        
        self.addSubview(fituLabel)
        self.addSubview(xButton)
        self.addSubview(checkButton)
        self.addSubview(undoButton)
        self.addSubview(beenthereButton)
    }

    func createDraggableViewWithDataAtIndex(_ index: NSInteger) -> DraggableView {
        let draggableView = DraggableView(frame: CGRect(x: (self.frame.size.width - CARD_WIDTH)/2, y: (self.frame.size.height - CARD_HEIGHT)/2 - 24, width: CARD_WIDTH, height: CARD_HEIGHT))
       
        
        // this is the place to configure all the detail of a new card so we will be updating server data here
        draggableView.restrauName.text = restaurants[index].name
        draggableView.cuisines.text = restaurants[index].cuisines
        let imageData = NSData(base64Encoded: restaurants[index].mainImage, options:  NSData.Base64DecodingOptions(rawValue: 0))
        draggableView.restrauImage.image = UIImage(data: imageData as! Data,scale:1.0)
        draggableView.imageButton.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
        draggableView.delegate = self
        return draggableView
    }

    
    func ratingButtonTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RestaurantDetail") as! RestaurantDetail
        vc.restrau = self.restaurants[cardsLoadedIndex]
        MyUtility.firstAvailableUIViewController(fromResponder:self)?.navigationController?.pushViewController(vc,animated: true)
    }
    
    func loadCards() -> Void {
        if exampleCardLabels.count > 0 {
            let numLoadedCardsCap = exampleCardLabels.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : exampleCardLabels.count
            for i in 0 ..< restaurants.count {
                let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }   
            }

            for i in 0 ..< loadedCards.count {
                if i > 0 {
                    self.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
    }

    func cardSwipedLeft(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)

        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    func cardSwipedRight(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }

    func cardSwipedTop(_ card: UIView) -> Void {
        loadedCards.remove(at: 0)
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
        
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeRight)
        UIView.animate(withDuration: 2.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()
    }

    func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        let dragView: DraggableView = loadedCards[0]
       
        dragView.overlayView.setMode(GGOverlayViewMode.ggOverlayViewModeLeft)
        UIView.animate(withDuration: 2.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
}
