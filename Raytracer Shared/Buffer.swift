//
//  Buffer.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import Foundation
import simd

class Buffer {
    typealias Pixel = UInt32
    typealias Row = [Pixel]

    struct Size {
        var width: Int, height: Int
    }

    var rows: [Row]
    let size: Size

    init(size: Buffer.Size) {
        self.size = size

        let emptyRow = Row(repeating: Pixel.red, count: size.width)
        self.rows = Array<Row>(repeating: emptyRow, count: size.height)
    }

    convenience init(size: CGSize) {
        self.init(size: Buffer.Size(width: Int(size.width), height: Int(size.height)))
    }
}

extension Buffer.Pixel {
    static let red: Self = 0xff0000ff
    static let white: Self = 0xffffffff
    static let blue: Self = 0xffff0000
    static let sky: Self = 0xffffb480

    var rgba: SIMD4<Float> {
        return SIMD4<Float>(
            x: Float((self & 0xff000000) >> 24),
            y: Float((self & 0xff0000) >> 16),
            z: Float((self & 0xff00) >> 8),
            w: Float(self & 0xff)
        )
    }

    init(_ rgb: SIMD3<Float>) {
        self.init(SIMD4<Float>(x: Float(0xff), y: rgb.z, z: rgb.y, w: rgb.x))
    }

    init(_ rgba: SIMD4<Float>) {
        let clamped = rgba.clamped(lowerBound: Self.min.rgba, upperBound: Self.max.rgba)

        let value: UInt32 = (UInt32(clamped.x) << 24) | (UInt32(clamped.y) << 16) | (UInt32(clamped.z) << 8) | UInt32(clamped.w)
        self.init(value)
    }

    static func *(lhs: Float, rhs: Self) -> Self {
        Self(rhs.rgba * lhs)
    }
}
