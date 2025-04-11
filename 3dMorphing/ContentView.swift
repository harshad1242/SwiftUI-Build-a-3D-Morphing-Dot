//
//  ContentView.swift
//  3dMorphing
//
//  Created by Harshad Vaghela on 10/04/25.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var currentShape: MorphingShape = .torus
    @State private var isAnimating = true
    @State private var particleNode: SCNNode?
    @State private var colorTimer: Timer?
    
    private func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
    
    private func startColorTransition() {
        colorTimer?.invalidate()
        colorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            updateParticleColors()
        }
    }
    
    private func updateParticleColors() {
        guard let particleNode = particleNode else { return }
        for particle in particleNode.childNodes {
            if let geometry = particle.geometry as? SCNSphere,
               let material = geometry.materials.first {
                material.diffuse.contents = randomColor()
            }
        }
    }
    
    var body: some View {
        ZStack {
            SceneView(
                scene: createScene(),
                pointOfView: createCamera(),
                options: [.allowsCameraControl]
            )
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            startColorTransition()
        }
        .onDisappear {
            colorTimer?.invalidate()
        }
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1000
        ambientLight.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLight)
        
        // Add directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1000
        directionalLight.light?.color = UIColor.white
        directionalLight.position = SCNVector3(5, 5, 5)
        scene.rootNode.addChildNode(directionalLight)
        
        // Add particle system
        let particles = createParticleSystem()
        scene.rootNode.addChildNode(particles)
        particleNode = particles
        
        // Add multiple rotation animations
        let rotationX = CABasicAnimation(keyPath: "rotation")
        rotationX.fromValue = NSValue(scnVector4: SCNVector4(1, 0, 0, 0))
        rotationX.toValue = NSValue(scnVector4: SCNVector4(1, 0, 0, Float.pi * 2))
        rotationX.duration = 25
        rotationX.repeatCount = .infinity
        particles.addAnimation(rotationX, forKey: "rotationX")
        
        let rotationY = CABasicAnimation(keyPath: "rotation")
        rotationY.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotationY.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotationY.duration = 20
        rotationY.repeatCount = .infinity
        particles.addAnimation(rotationY, forKey: "rotationY")
        
        let rotationZ = CABasicAnimation(keyPath: "rotation")
        rotationZ.fromValue = NSValue(scnVector4: SCNVector4(0, 0, 1, 0))
        rotationZ.toValue = NSValue(scnVector4: SCNVector4(0, 0, 1, Float.pi * 2))
        rotationZ.duration = 30
        rotationZ.repeatCount = .infinity
        particles.addAnimation(rotationZ, forKey: "rotationZ")
        
        // Add pulsing animation
        let pulse = CABasicAnimation(keyPath: "scale")
        pulse.fromValue = NSValue(scnVector3: SCNVector3(0.9, 0.9, 0.9))
        pulse.toValue = NSValue(scnVector3: SCNVector3(1.1, 1.1, 1.1))
        pulse.duration = 2.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        particles.addAnimation(pulse, forKey: "pulse")
        
        return scene
    }
    
    private func createCamera() -> SCNNode {
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 0, 15)
        camera.camera?.zFar = 100
        return camera
    }
    
    private func createParticleSystem() -> SCNNode {
        let particleNode = SCNNode()
        let numberOfParticles = 2000
        
        for index in 0..<numberOfParticles {
            // Vary particle size
            let size = Float.random(in: 0.02...0.05)
            let sphere = SCNSphere(radius: CGFloat(size))
            
            let material = SCNMaterial()
            material.diffuse.contents = randomColor()
            material.lightingModel = .phong
            material.specular.contents = UIColor.white
            material.emission.contents = randomColor().withAlphaComponent(0.3)
            sphere.materials = [material]
            
            let particleDot = SCNNode(geometry: sphere)
            let position = MorphingAnimator.calculatePositionForShape(.sphere, index: index, totalParticles: numberOfParticles, spread: 1.0)
            particleDot.position = position
            
            // Add individual particle rotation
            let particleRotation = CABasicAnimation(keyPath: "rotation")
            particleRotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
            particleRotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            particleRotation.duration = Double.random(in: 5...15)
            particleRotation.repeatCount = .infinity
            particleDot.addAnimation(particleRotation, forKey: "rotation")
            
            particleNode.addChildNode(particleDot)
        }
        
        return particleNode
    }
    
    private func morphTo(_ shape: MorphingShape) {
        guard !isAnimating, let particleNode = particleNode else { return }
        isAnimating = true
        currentShape = shape
        
        MorphingAnimator.animateParticles(in: particleNode, to: shape, duration: 1.5, spread: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAnimating = false
        }
    }
}

enum MorphingShape {
    case sphere
    case cube
    case torus
}

#Preview {
    ContentView()
}
