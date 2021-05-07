//
//  MapViewModel.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 06/05/21.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel:NSObject, ObservableObject, CLLocationManagerDelegate  {
    @Published var mapView = MKMapView()
    
    @Published var region: MKCoordinateRegion!
    
    @Published var permissionDenied: Bool = false
    
    @Published var didRenderPinAndPath: Bool = false
    
    @Published var searchFieldText = ""
    
    @Published var locations: [Location] = [Location]()
    
    @Published var searchResultsError: Error?
    
    @Published var currentUserLocation: CLLocation?
    
    @Published var directionsNotFoundError = false
    
    @State var dataManager = coreDataManager()
    
    func searchLocations() {
        self.locations.removeAll()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchFieldText
        
        // start fetch
        MKLocalSearch(request: request).start(completionHandler: {(response, error) in
            if let error = error {
                self.searchResultsError = error
            }
            guard let results = response else { return }
            self.locations = results.mapItems.compactMap({ Item -> Location? in
                return Location(location: Item.placemark)
            })
        })
    }

    func drawPinAndPathForSelectionLocation(location: CLLocationCoordinate2D, name: String, isFromHistoryView: Bool = false) {
        guard let currentUserLocation = currentUserLocation else {
            return
        }
        let selectedLocationMarker = MKPointAnnotation()
        selectedLocationMarker.coordinate = location
        selectedLocationMarker.title = name
        
        let currentUserLocationMarker = MKPointAnnotation()
        currentUserLocationMarker.coordinate = currentUserLocation.coordinate
        currentUserLocationMarker.title = "My location"
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(selectedLocationMarker)
        mapView.addAnnotation(currentUserLocationMarker)
        
        let getDirectionsRequest = MKDirections.Request()
        getDirectionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
        getDirectionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: location))
        
        let directions = MKDirections(request: getDirectionsRequest)
        directions.calculate { (directionsResponse, error) in
            if error != nil {
                print("MapViewModel " + error!.localizedDescription)
                if (error!.localizedDescription == "Directions Not Available"){
                    self.directionsNotFoundError = true
                    self.mapView.removeAnnotations(self.mapView.annotations)
                }
                return
            }
            if let fastestRoute = directionsResponse?.routes.first?.polyline {
                self.mapView.addOverlay(fastestRoute)
                self.mapView.setRegion(MKCoordinateRegion(fastestRoute.boundingMapRect), animated: true)
                self.mapView.setVisibleMapRect(fastestRoute.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            }
        }
        if (!isFromHistoryView) {
            dataManager.saveSearchedLocation(location: location, name: name)
        }
        locations.removeAll()
        mapView.removeOverlays(mapView.overlays)
        didRenderPinAndPath = true
    }
    
    
    
    // MARK: - Location Manager Delegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            permissionDenied.toggle()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
        ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("MapViewModel:" + (error.localizedDescription))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.currentUserLocation = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        //update map region
        mapView.setRegion(self.region, animated: true)
        mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
}
