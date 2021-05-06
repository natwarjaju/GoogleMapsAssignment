//
//  MapView.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 06/05/21.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var mapViewModel: MapViewModel

    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView{
        let view = self.mapViewModel.mapView
        
        view.showsUserLocation = true
        view.delegate = context.coordinator
        
        return view
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 2
            return renderer
        }
    
    }
}
