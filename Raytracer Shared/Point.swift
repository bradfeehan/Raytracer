//
//  Point.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import simd

typealias Point = SIMD3<Float>

extension Point {
    static let origin = Self(0, 0, 0)
}
