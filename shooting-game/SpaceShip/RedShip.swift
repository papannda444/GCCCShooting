//
//  RedShip.swift
//  shooting-game
//
//  Created by papannda444 on 2019/03/03.
//  Copyright © 2019 三野田脩. All rights reserved.
//

import Foundation
import SpriteKit

class RedShip: SKSpriteNode {
    weak var delegate: SpaceShipDelegate?

    var state = SpaceShipState() {
        didSet {
            let statusTexture: SKTexture?
            switch state {
            case .normal:
                statusTexture = nil
            default:
                // state is .speed or .stone
                statusTexture = SKTexture(imageNamed: state.rawValue)
            }

            delegate?.updateShipState(statusTexture: statusTexture)
        }
    }
    var level = SpaceShipLevel() {
        didSet {
            delegate?.levelUpShip(level: level)
        }
    }
    var moveSpeed: CGFloat = 0.0
    var hearts: [SKSpriteNode] = []
    var maxHitPoint: Int = 0
    var bulletTimer: Timer?
    var timerForPowerItem: Timer?

    convenience init(moveSpeed: CGFloat, displayViewFrame frame: CGRect) {
        let texture = SKTexture(imageNamed: SpaceShipType.red.rawValue)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.moveSpeed = moveSpeed
        position = CGPoint(x: 0, y: frame.height / 2 - self.frame.height)
        scale(to: CGSize(width: 90, height: 90))
        physicsBody = SKPhysicsBody(circleOfRadius: self.frame.width / 4)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RedShip: SpaceShip {
    func damaged(_ enemy: Enemy? = nil) {
        if isShipState(equal: .stone) {
            enemy?.damaged()
            delegate?.scoreUp(of: 1)
            return
        }

        guard let heart = hearts.popLast() else {
            return
        }
        heart.removeFromParent()

        if hearts.isEmpty { delegate?.lostAllHearts() }
    }

    func touchViewBegin(touchedViewFrame frame: CGRect) {
        bulletTimer?.invalidate()
        let moveToTop = SKAction.sequence([
            SKAction.moveTo(y: frame.height + 10, duration: 1.0),
            SKAction.removeFromParent()
        ])
        let bullet = Bullet(bulletType: .red, bulletLevel: level, position: position)
        bullet.run(moveToTop)
        delegate?.addBullet(bullet: bullet)
        bulletTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self, level] _ in
            guard let position = self?.position else {
                return
            }
            let bullet = Bullet(bulletType: .red, bulletLevel: level, position: position)
            bullet.run(moveToTop)
            self?.delegate?.addBullet(bullet: bullet)

            if self?.level == .one {
                return
            }
            let leftBullet = Bullet(bulletType: .red,
                                    bulletLevel: level,
                                    position: CGPoint(x: position.x - 30, y: position.y - 30))
            leftBullet.run(moveToTop)
            self?.delegate?.addBullet(bullet: leftBullet)

            if self?.level == .two {
                return
            }
            let rightBullet = Bullet(bulletType: .red,
                                     bulletLevel: level,
                                     position: CGPoint(x: position.x + 30, y: position.y - 30))
            rightBullet.run(moveToTop)
            self?.delegate?.addBullet(bullet: rightBullet)
        }
    }
}
