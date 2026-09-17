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
        // SwiftUI calls updateUIView before the view has a size and not again
        // after layout, so waiting for non-zero bounds there never presents a
        // scene. Present now with a placeholder size; resizeFill plus the
        // scene's didChangeSize take care of the real dimensions.
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {}
}
