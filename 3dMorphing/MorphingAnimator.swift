import SceneKit

class MorphingAnimator {
    static func calculatePositionForShape(_ shape: MorphingShape, index: Int, totalParticles: Int, spread: Float) -> SCNVector3 {
        switch shape {
        case .sphere:
            return calculateSpherePosition(index: index, totalParticles: totalParticles, spread: spread)
        case .cube:
            return calculateCubePosition(index: index, totalParticles: totalParticles, spread: spread)
        case .torus:
            return calculateTorusPosition(index: index, totalParticles: totalParticles, spread: spread)
        }
    }
    
    private static func calculateSpherePosition(index: Int, totalParticles: Int, spread: Float) -> SCNVector3 {
        let baseRadius: Float = 3.0
        let radius = baseRadius * spread
        let golden_ratio: Float = (1.0 + sqrt(5.0)) / 2.0
        let theta = 2.0 * .pi * Float(index) / golden_ratio
        let phi = acos(1.0 - 2.0 * Float(index) / Float(totalParticles))
        
        let x = radius * sin(phi) * cos(theta)
        let y = radius * sin(phi) * sin(theta)
        let z = radius * cos(phi)
        
        return SCNVector3(x, y, z)
    }
    
    private static func calculateCubePosition(index: Int, totalParticles: Int, spread: Float) -> SCNVector3 {
        let baseSideLength: Float = 4.0
        let sideLength = baseSideLength * spread
        let particlesPerSide = Int(pow(Float(totalParticles), 1/3))
        let spacing = sideLength / Float(particlesPerSide)
        
        let x = Float(index % particlesPerSide) * spacing - sideLength/2
        let y = Float((index / particlesPerSide) % particlesPerSide) * spacing - sideLength/2
        let z = Float(index / (particlesPerSide * particlesPerSide)) * spacing - sideLength/2
        
        return SCNVector3(x, y, z)
    }
    
    private static func calculateTorusPosition(index: Int, totalParticles: Int, spread: Float) -> SCNVector3 {
        let baseMajorRadius: Float = 3.0 // Major radius
        let baseMinorRadius: Float = 1.0 // Minor radius
        let R = baseMajorRadius * spread
        let r = baseMinorRadius * spread
        let theta = 2.0 * .pi * Float(index) / Float(totalParticles)
        let phi = 2.0 * .pi * Float(index) / Float(sqrt(Float(totalParticles)))
        
        let x = (R + r * cos(phi)) * cos(theta)
        let y = (R + r * cos(phi)) * sin(theta)
        let z = r * sin(phi)
        
        return SCNVector3(x, y, z)
    }
    
    static func animateParticles(in node: SCNNode, to shape: MorphingShape, duration: TimeInterval = 1.0, spread: Float) {
        let totalParticles = node.childNodes.count
        
        for (index, particleNode) in node.childNodes.enumerated() {
            let targetPosition = calculatePositionForShape(shape, index: index, totalParticles: totalParticles, spread: spread)
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = particleNode.presentation.position
            animation.toValue = targetPosition
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            particleNode.addAnimation(animation, forKey: "position")
            particleNode.position = targetPosition
        }
    }
} 