//
//  Scene.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

typealias Scene = [Hitable]

extension Scene: Hitable {
    func hit(by ray: Camera.Ray, within range: Range<Float>) -> Hit? {
        var closest = range.upperBound
        var maybeHit: Hit?

        self.forEach { hitable in
            if let hit = hitable.hit(by: ray, within: range.lowerBound..<closest) {
                closest = hit.distance
                maybeHit = hit
            }
        }

        return maybeHit
    }
}
