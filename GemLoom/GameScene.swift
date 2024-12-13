//
//  GameScene.swift
//  GemLoom
//
//  Created by Robert Libšanský on 13.12.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let colors: [UIColor] = [.red, .green, .blue]
    let circleRadius: CGFloat = 50.0
    let numberOfCircles = 6
    var lastUpdateTime: TimeInterval = 0
    var selectedCircles: [SKShapeNode] = []

    override func didMove(to view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    }

    func touchDown(atPoint pos : CGPoint) {
        guard let touchedNode = self.nodes(at: pos).first as? SKShapeNode else { return }
        if selectedCircles.contains(touchedNode) { return }

        touchedNode.alpha = 0.5
        selectedCircles.append(touchedNode)
    }

    func touchMoved(toPoint pos : CGPoint) {
        guard let touchedNode = self.nodes(at: pos).first as? SKShapeNode else { return }
        if selectedCircles.contains(touchedNode) { return }

        if let firstSelected = selectedCircles.first, firstSelected.fillColor == touchedNode.fillColor {
            touchedNode.alpha = 0.5
            selectedCircles.append(touchedNode)
        }
    }

    func touchUp(atPoint pos : CGPoint) {
        if selectedCircles.count >= 3 {
            let firstSelected = selectedCircles.first!
            let connectedCircles = findConnectedCircles(from: firstSelected)

            removeCircles(connectedCircles)
        } else {
            resetCircles()
        }

        selectedCircles.removeAll()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastUpdateTime > 2 {
            spawnCircles()
            lastUpdateTime = currentTime
        }
    }

    func findConnectedCircles(from startNode: SKShapeNode) -> [SKShapeNode] {
        var connectedCircles: [SKShapeNode] = []
        var nodesToCheck: [SKShapeNode] = [startNode]

        while !nodesToCheck.isEmpty {
            let node = nodesToCheck.removeFirst()

            if connectedCircles.contains(node) { continue }

            connectedCircles.append(node)

            let neighbors = getNeighbors(of: node)

            for neighbor in neighbors {
                if neighbor.fillColor == startNode.fillColor && !connectedCircles.contains(neighbor) {
                    nodesToCheck.append(neighbor)
                }
            }
        }

        return connectedCircles
    }

    func getNeighbors(of node: SKShapeNode) -> [SKShapeNode] {
        var neighbors: [SKShapeNode] = []
        let nodePosition = node.position

        let positionsToCheck = [
            CGPoint(x: nodePosition.x - circleRadius * 2, y: nodePosition.y),
            CGPoint(x: nodePosition.x + circleRadius * 2, y: nodePosition.y),
            CGPoint(x: nodePosition.x, y: nodePosition.y - circleRadius * 2),
            CGPoint(x: nodePosition.x, y: nodePosition.y + circleRadius * 2)
        ]

        for position in positionsToCheck {
            let nodesAtPosition = self.nodes(at: position)

            for neighbor in nodesAtPosition {
                if let shapeNode = neighbor as? SKShapeNode {
                    neighbors.append(shapeNode)
                }
            }
        }

        return neighbors
    }

    func removeCircles(_ circles: [SKShapeNode]) {
        for circle in circles {
            circle.removeFromParent()
        }
    }

    func resetCircles() {
        for circle in selectedCircles {
            circle.alpha = 1
        }
    }

    func spawnCircles() {
        let circleDiameter = circleRadius * 2
        let spacing = (self.size.width - (circleDiameter * CGFloat(numberOfCircles))) / CGFloat(numberOfCircles + 1)

        for i in 0..<numberOfCircles {
            let circle = SKShapeNode(circleOfRadius: circleRadius)

            circle.fillColor = colors.randomElement()!
            circle.position = CGPoint(
                x: spacing + circleDiameter / 2 + CGFloat(i) * (circleDiameter + spacing),
                y: self.size.height - circleRadius)
            circle.physicsBody = SKPhysicsBody(circleOfRadius: circleRadius)
            circle.physicsBody?.restitution = 0.5
            circle.physicsBody?.isDynamic = true
            circle.physicsBody?.allowsRotation = false

            self.addChild(circle)
        }
    }
}
