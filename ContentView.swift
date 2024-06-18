//
// ContentView.swift
//
// Created by Speedyfriend67 on 18.06.24
//
 
import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @State var arView: ARView?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        self.arView = arView
        
        // AR Configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        var arView: ARView?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            
            let results = arView.hitTest(location, types: [.existingPlaneUsingExtent])
            
            if let firstResult = results.first {
                let anchor = ARAnchor(name: "object", transform: firstResult.worldTransform)
                arView.session.add(anchor: anchor)
                
                let box = ModelEntity(mesh: .generateBox(size: 0.1))
                box.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
                
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(box)
                
                arView.scene.anchors.append(anchorEntity)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}