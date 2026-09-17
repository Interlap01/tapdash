import SwiftUI
import SpriteKit

@main
struct TapDashApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}

struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.ignoresSiblingOrder = true
        view.isMultipleTouchEnabled = false
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        guard view.scene == nil, view.bounds.width > 0, view.bounds.height > 0 else { return }
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
    }
}
