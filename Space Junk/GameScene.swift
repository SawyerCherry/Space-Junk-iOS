//
//  GameScene.swift
//  Space Junk
//
//  Created by Sawyer Cherry on 10/20/21.
//
import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Ship: UInt32 = 0b1
    static let Debris: UInt32 = 0b100
    static let Edge: UInt32 = 0b1000
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
    
        let contactAMask = contact.bodyA.contactTestBitMask
        let contactBMask =  contact.bodyB.contactTestBitMask
        
        let collision = contactAMask | contactBMask
        
        if collision == PhysicsCategory.Debris | PhysicsCategory.Ship {
            
            
            let debrisNode: SKNode = {
                let nodeA = contact.bodyA.node!
                
                if nodeA.name == "debris" {
                    return nodeA
                }
                
                let nodeB = contact.bodyB.node!
                if nodeB.name == "debris" {
                    return nodeB
                }
                
                fatalError("oops")
                
            }()
            debrisNode.removeFromParent()
            displayGameOver()
        } else if collision == PhysicsCategory.Debris {
            print("debris")
        }
    }
    func didEnd(_ contact: SKPhysicsContact) {
       
    }
}




class GameScene: SKScene {
    var ship: SKSpriteNode!
    
    
    
    func pickRandomSprite() -> String {
        return [
            "meteorBrown_big3",
            "meteorGrey_big4",
            "meteorGrey_med1",
            "wingGreen_6",
            "wingRed_2"
        ].randomElement()!
    }
    
    override func didMove(to view: SKView) {
//        let musica: SKAction = SKAction.playSoundFileNamed("greasy.mp3", waitForCompletion: false)
//        run(musica)
        physicsWorld.contactDelegate = self

        ship = (childNode(withName: "player") as! SKSpriteNode)
        
        let spawnDebris = SKAction.run {
        
            //create the debris
            let debris = SKSpriteNode(imageNamed: self.pickRandomSprite())
            //position them at the top, randomly
            let screenWidth = self.size.width
            debris.position.x = CGFloat.random(in: 0...screenWidth)
            debris.position.y = self.size.height
            debris.name = "debris"
            let radius = max(debris.size.width / 2, debris.size.height / 2)
            debris.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            debris.physicsBody?.categoryBitMask = PhysicsCategory.Debris
            debris.physicsBody?.collisionBitMask = PhysicsCategory.Ship | PhysicsCategory.Debris
            debris.physicsBody?.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Debris
            
            
            self.addChild(debris)
            
            //spinning
            
            debris.physicsBody?.applyAngularImpulse(0.01)
            
            
            // when off of the screen, remove it
            
            
            
            
           
        
        }
        
        let spawnStuff = SKAction.repeatForever(.sequence([spawnDebris, .wait(forDuration: 1)]))
        self.run(spawnStuff)
        
        
        
        
        
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        
        let touchLocation = firstTouch.location(in: self)
        
        let moveToTouchLocationAction = SKAction.moveTo(x: touchLocation.x, duration: 1)
        
        let playerNode = childNode(withName: "player")!
        
        playerNode.run(moveToTouchLocationAction)
        
        
    }
    
    func debrisHitShip(debris: SKSpriteNode) {
        if let fireEmitter = SKEmitterNode(fileNamed: "Fire.sks") {
            fireEmitter.position = debris.position
            addChild(fireEmitter)
        }
        debris.removeFromParent()
    }
    
    func displayGameOver() {
        let gameOverScene = GameOverScene(fileNamed: "GameOver")!
        gameOverScene.scaleMode = .aspectFill
        view?.presentScene(gameOverScene)
    }
    
}

class GameOverScene: SKScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let game =  GameScene(fileNamed: "GameScene")!
        game.scaleMode = .aspectFill
        view?.presentScene(game)
    }
}

