//
//  Direction.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import Foundation

typealias Direction = Point

extension Direction {
    var length: Float { (pow(x, 2) + pow(y, 2) + pow(z, 2)).squareRoot() }
    var unit: Self { self / self.length }

    static func randomInUnitSphere() -> Self {
        var point: Self

        repeat {
            point = 2 * Self(Float(drand48()), Float(drand48()), Float(drand48())) - Self.one
        } while point.length >= 1

        return point
    }
}

