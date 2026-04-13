//
//  GameScene.swift
//  arkanoidIA
//
//  Created by Yael Javier Zamora Moreno on 12/04/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let ballCategory: UInt32 = 0x1 << 0
    let paddleCategory: UInt32 = 0x1 << 1
    let brickCategory: UInt32 = 0x1 << 2
    let borderCategory: UInt32 = 0x1 << 3
    let bottomCategory: UInt32 = 0x1 << 4
    
    var paddle: SKSpriteNode!
    var ball: SKSpriteNode!
    var gameOverLabel: SKLabelNode!
    var restartButton: SKLabelNode!
    
    var isGameOver = false
    var bricksBroken = 0
    var baseBallSpeed: CGFloat = 400.0
    
    var lastBorderTouchY: CGFloat?
    var consecutiveBorderTouches = 0
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        setupGame()
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    func setupGame() {
        self.removeAllChildren()
        
        isGameOver = false
        bricksBroken = 0
        baseBallSpeed = 400.0
        
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.categoryBitMask = borderCategory
        self.physicsBody = borderBody
        
        let bottomRect = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: 1)
        let bottomNode = SKNode()
        bottomNode.position = CGPoint(x: 0, y: 0)
        let bottomBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        bottomBody.categoryBitMask = bottomCategory
        bottomBody.contactTestBitMask = ballCategory
        bottomNode.physicsBody = bottomBody
        self.addChild(bottomNode)
        
        paddle = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 20))
        let lowerThirdY = self.frame.minY + self.frame.height * 0.15
        paddle.position = CGPoint(x: 0, y: lowerThirdY)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1
        paddle.physicsBody?.categoryBitMask = paddleCategory
        self.addChild(paddle)
        
        ball = SKSpriteNode(color: .white, size: CGSize(width: 15, height: 15))
        ball.position = CGPoint(x: 0, y: paddle.position.y + 30)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory | borderCategory | paddleCategory
        ball.physicsBody?.collisionBitMask = borderCategory | paddleCategory | brickCategory
        self.addChild(ball)
        
        ball.physicsBody?.velocity = CGVector(dx: 200, dy: baseBallSpeed)
        
        setupBricks()
    }
    
    func setupBricks() {
        let rows = 5
        let cols = 7
        let brickWidth = (self.frame.width - 40) / CGFloat(cols)
        let brickHeight: CGFloat = 20.0
        let colors: [SKColor] = [.red, .orange, .yellow, .green, .cyan]
        
        let startX = self.frame.minX + 20 + brickWidth / 2
        let startY = self.frame.maxY - 100
        
        for row in 0..<rows {
            let color = colors[row % colors.count]
            for col in 0..<cols {
                let brick = SKSpriteNode(color: color, size: CGSize(width: brickWidth - 6, height: brickHeight))
                brick.position = CGPoint(x: startX + CGFloat(col) * brickWidth,
                                         y: startY - CGFloat(row) * (brickHeight + 6))
                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
                brick.physicsBody?.isDynamic = false
                brick.physicsBody?.categoryBitMask = brickCategory
                self.addChild(brick)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if isGameOver { return }
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == bottomCategory || bodyB.categoryBitMask == bottomCategory {
            gameOver()
            return
        }
        
        if bodyA.categoryBitMask == borderCategory || bodyB.categoryBitMask == borderCategory {
            let touchY = contact.contactPoint.y
            if let lastY = lastBorderTouchY, abs(lastY - touchY) < 10.0 {
                consecutiveBorderTouches += 1
                if consecutiveBorderTouches >= 2 {
                    if let ballBody = ball.physicsBody {
                        let currentSpeed = sqrt(ballBody.velocity.dx * ballBody.velocity.dx + ballBody.velocity.dy * ballBody.velocity.dy)
                        let speedToUse = max(currentSpeed, baseBallSpeed)
                        let component = speedToUse / 1.4142 // Constante para ~45 grados
                        let directionX: CGFloat = ballBody.velocity.dx >= 0 ? 1.0 : -1.0
                        
                        ballBody.velocity = CGVector(dx: directionX * component, dy: -component)
                    }
                    consecutiveBorderTouches = 0
                }
            } else {
                consecutiveBorderTouches = 1
                lastBorderTouchY = touchY
            }
        } else if bodyA.categoryBitMask == paddleCategory || bodyB.categoryBitMask == paddleCategory {
            consecutiveBorderTouches = 0
            
            if let ballBody = ball.physicsBody {
                let offset = ball.position.x - paddle.position.x
                let directionX: CGFloat = offset >= 0 ? 1.0 : -1.0
                
                let currentDx = abs(ballBody.velocity.dx)
                let currentDy = abs(ballBody.velocity.dy)
                
                ballBody.velocity = CGVector(dx: directionX * currentDx, dy: currentDy)
            }
        }
        
        var brickBody: SKPhysicsBody?
        if bodyA.categoryBitMask == brickCategory { brickBody = bodyA }
        else if bodyB.categoryBitMask == brickCategory { brickBody = bodyB }
        
        if let brick = brickBody?.node as? SKSpriteNode {
            breakBrick(brick)
            consecutiveBorderTouches = 0
        }
    }
    
    func breakBrick(_ brick: SKSpriteNode) {
        let emitter = SKEmitterNode()
        emitter.particleColor = brick.color
        emitter.particleColorSequence = nil
        emitter.particleColorBlendFactor = 1.0
        emitter.particleSize = CGSize(width: 5, height: 5)
        emitter.particleBirthRate = 500
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.5
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngleRange = .pi * 2
        emitter.position = brick.position
        
        self.addChild(emitter)
        
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
        
        brick.removeFromParent()
        bricksBroken += 1
        
        if bricksBroken % 5 == 0 {
            baseBallSpeed *= 1.1
            if let v = ball.physicsBody?.velocity {
                let currentSpeed = sqrt(v.dx*v.dx + v.dy*v.dy)
                let speedRatio = baseBallSpeed / currentSpeed
                ball.physicsBody?.velocity = CGVector(dx: v.dx * speedRatio, dy: v.dy * speedRatio)
            }
        }
    }
    
    func gameOver() {
        isGameOver = true
        ball.removeFromParent()
        
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: 0, y: 20)
        self.addChild(gameOverLabel)
        
        restartButton = SKLabelNode(text: "Reiniciar")
        restartButton.fontSize = 20
        restartButton.position = CGPoint(x: 0, y: -40)
        restartButton.name = "restart"
        self.addChild(restartButton)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isGameOver {
            if let touch = touches.first {
                let location = touch.location(in: self)
                let nodesAtLocation = self.nodes(at: location)
                if nodesAtLocation.contains(where: { $0.name == "restart" }) {
                    setupGame()
                }
            }
            return
        }
        
        if let touch = touches.first {
            paddle.position.x = touch.location(in: self).x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
        if let touch = touches.first {
            paddle.position.x = touch.location(in: self).x
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver, let body = ball?.physicsBody else { return }
        
        let velocity = body.velocity
        let minVelocity_Y: CGFloat = 80.0
        let minVelocity_X: CGFloat = 80.0
        
        var dx = velocity.dx
        var dy = velocity.dy
        
        if abs(dy) < minVelocity_Y {
            dy = dy >= 0 ? minVelocity_Y : -minVelocity_Y
        }
        if abs(dx) < minVelocity_X {
            dx = dx >= 0 ? minVelocity_X : -minVelocity_X
        }
        
        body.velocity = CGVector(dx: dx, dy: dy)
        
        let currentSpeed = sqrt(dx*dx + dy*dy)
        if currentSpeed > baseBallSpeed * 1.5 {
            let ratio = baseBallSpeed / currentSpeed
            body.velocity = CGVector(dx: dx * ratio, dy: dy * ratio)
        }
    }
}
