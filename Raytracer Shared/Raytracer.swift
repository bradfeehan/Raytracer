//
//  Raytracer.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import Foundation
import simd

class Raytracer {
    private static let SAMPLES = 100

    private var camera: Camera
    public var buffer: Buffer

    typealias Scene = [Hitable]
    private static let scene: Scene = [
        Sphere(center: Point(0, 0, -1), radius: 0.5),
        Sphere(center: Point(0, -100.5, -1), radius: 100),
    ]

    typealias Color = SIMD3<Float>

    init(size: CGSize) {
        self.buffer = Buffer(size: size)
        self.camera = Camera(size: self.buffer.size)
    }

    func run() {
        for rowIndex in 0..<buffer.size.height {
            let y = rowIndex

            for columnIndex in 0..<buffer.size.width {
                let x = columnIndex

                let samples = (0..<Self.SAMPLES).map { sampleIndex -> Color in
                    let u = (Float(x) + randomFloat()) / Float(self.buffer.size.width)
                    let v = (Float(y) + randomFloat()) / Float(self.buffer.size.height)

                    return self.color(of: self.camera.ray(u, v))
                }

                self.buffer.rows[rowIndex][columnIndex] = (samples.reduce(Color.black, +) / Float(samples.count)).pixel
            }
        }
    }

    private func randomFloat() -> Float {
        return Float(drand48())
    }

    private func color(of ray: Camera.Ray) -> Color {
        if let hit = Self.scene.hit(by: ray, within: 0.0..<Float.greatestFiniteMagnitude) {
            return Color(0.5 * (hit.normal + 1))
        }

        let unitDirection = ray.direction.unit
        let t = 0.5 * (unitDirection.y + 1)
        return (1 - t) * Color.white + t * Color.sky
    }
}

extension Raytracer.Color {
    static let red = Self(1, 0, 0)
    static let white = Self(1, 1, 1)
    static let black = Self(0, 0, 0)
    static let blue = Self(0, 0, 1)
    static let sky = Self(0.5, 0.7, 1)

    var pixel: Buffer.Pixel {
        return Buffer.Pixel(self * 0xff)
    }
}

