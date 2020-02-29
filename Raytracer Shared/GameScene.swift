//
//  GameScene.swift
//  Raytracer Shared
//
//  Created by Brad Feehan on 28/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    fileprivate var raytracer: Raytracer?
    fileprivate var screen: SKSpriteNode?
    fileprivate var texture: SKMutableTexture?

    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            fatalError("Failed to load GameScene.sks")
        }

        scene.scaleMode = .resizeFill

        return scene
    }

    func setUpScene() {
        guard let screen = self.childNode(withName: "//Screen") as? SKSpriteNode else {
            fatalError("Couldn't find screen node")
        }

        self.texture = SKMutableTexture(size: screen.size)
        screen.texture = self.texture

        self.screen = screen

        self.raytracer = Raytracer(size: screen.size)

        DispatchQueue.global(qos: .userInitiated).async {
            self.raytracer?.run()
        }
    }

    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    override func update(_ currentTime: TimeInterval) {
        guard let raytracer = self.raytracer else { return }

        self.texture?.modifyPixelData { (pointer: UnsafeMutableRawPointer?, lengthInBytes: Int) in
//            arc4random_buf(pointer, lengthInBytes)

            let pixelCount = lengthInBytes / MemoryLayout<UInt32>.stride
            guard let pixels = pointer?.bindMemory(to: UInt32.self, capacity: pixelCount) else { return }

            let width = raytracer.buffer.size.width

            for pixelIndex in 0..<pixelCount {
                let columnIndex = pixelIndex % width
                let rowIndex = pixelIndex / width
                pixels[pixelIndex] = raytracer.buffer.rows[rowIndex][columnIndex]
            }
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        //
    }

    override func mouseDragged(with event: NSEvent) {
        //
    }

    override func mouseUp(with event: NSEvent) {
        //
    }
}
#endif

