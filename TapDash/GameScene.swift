import SpriteKit

final class GameScene: SKScene {

    private enum Layout {
        static let shapeRadius: CGFloat = 34
        static let spawnInterval: TimeInterval = 0.85
        static let baseFallDuration: TimeInterval = 3.0
        static let minFallDuration: TimeInterval = 0.9
    }

    private let palette: [SKColor] = [
        SKColor(red: 0.98, green: 0.36, blue: 0.42, alpha: 1),
        SKColor(red: 0.30, green: 0.74, blue: 0.98, alpha: 1),
        SKColor(red: 0.99, green: 0.78, blue: 0.28, alpha: 1),
        SKColor(red: 0.46, green: 0.86, blue: 0.56, alpha: 1),
        SKColor(red: 0.72, green: 0.54, blue: 0.98, alpha: 1)
    ]

    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var overlay: SKNode?

    private var score = 0
    private var missed = 0
    private var speedFactor: Double = 1.0
    private var isOver = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.08, blue: 0.14, alpha: 1)
        configureLabels()
        startRound()
    }

    // MARK: - Setup

    private func configureLabels() {
        scoreLabel.fontSize = 44
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = 10
        addChild(scoreLabel)

        livesLabel.fontSize = 22
        livesLabel.fontColor = SKColor(white: 1, alpha: 0.65)
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.verticalAlignmentMode = .top
        livesLabel.zPosition = 10
        addChild(livesLabel)

        layoutLabels()
    }

    private func layoutLabels() {
        let inset: CGFloat = 24
        let top = size.height - 64
        scoreLabel.position = CGPoint(x: inset, y: top)
        livesLabel.position = CGPoint(x: size.width - inset, y: top)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutLabels()
    }

    // MARK: - Round lifecycle

    private func startRound() {
        isOver = false
        score = 0
        missed = 0
        speedFactor = 1.0
        overlay?.removeFromParent()
        overlay = nil
        updateLabels()

        let spawn = SKAction.run { [weak self] in self?.spawnShape() }
        let wait = SKAction.wait(forDuration: Layout.spawnInterval, withRange: 0.35)
        run(.repeatForever(.sequence([spawn, wait])), withKey: "spawn")
    }

    private func updateLabels() {
        scoreLabel.text = "\(score)"
        livesLabel.text = String(repeating: "●", count: max(0, 3 - missed))
    }

    private func spawnShape() {
        guard !isOver else { return }
        let radius = Layout.shapeRadius
        let shape = SKShapeNode(circleOfRadius: radius)
        shape.fillColor = palette.randomElement() ?? .white
        shape.strokeColor = .clear
        shape.name = "shape"

        let x = CGFloat.random(in: (radius + 12)...(size.width - radius - 12))
        shape.position = CGPoint(x: x, y: size.height + radius)

        let duration = max(Layout.minFallDuration, Layout.baseFallDuration / speedFactor)
        let fall = SKAction.moveTo(y: -radius, duration: duration)
        let miss = SKAction.run { [weak self] in self?.registerMiss() }
        shape.run(.sequence([fall, miss, .removeFromParent()]))
        addChild(shape)
    }

    private func registerMiss() {
        guard !isOver else { return }
        missed += 1
        updateLabels()
        if missed >= 3 { endRound() }
    }

    private func endRound() {
        isOver = true
        removeAction(forKey: "spawn")
        children.filter { $0.name == "shape" }.forEach { $0.removeAllActions(); $0.removeFromParent() }

        let node = SKNode()
        node.zPosition = 20

        let dim = SKSpriteNode(color: SKColor(white: 0, alpha: 0.6), size: size)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        node.addChild(dim)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "Score \(score)"
        title.fontSize = 52
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 16)
        node.addChild(title)

        let hint = SKLabelNode(fontNamed: "AvenirNext-Medium")
        hint.text = "Tap to restart"
        hint.fontSize = 24
        hint.fontColor = SKColor(white: 1, alpha: 0.8)
        hint.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)
        node.addChild(hint)

        addChild(node)
        overlay = node
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        if isOver {
            startRound()
            return
        }

        let hit = nodes(at: location).first { $0.name == "shape" }
        guard let shape = hit else { return }

        shape.name = nil
        shape.removeAllActions()
        shape.run(.sequence([
            .group([.scale(to: 1.5, duration: 0.15), .fadeOut(withDuration: 0.15)]),
            .removeFromParent()
        ]))

        score += 1
        speedFactor = min(3.0, speedFactor + 0.03)
        updateLabels()
    }
}
