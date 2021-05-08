//
//  SearchLocationsScreen.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 06/05/21.
//

import SwiftUI
import CoreLocation

struct SearchLocationsScreen: View {
    @ObservedObject var viewModel = MapViewModel()

    @State var locationManager = CLLocationManager()
    
    @State var shouldDisplayHistoryScreen: Bool = false
    
    @State var shouldSignOut = false
    
    var body: some View {
        ZStack{
            MapView()
                .environmentObject(viewModel)
                .ignoresSafeArea(.all, edges: .all)
            VStack {
                HStack(spacing: 0) {
                    TextField("Search", text: $viewModel.searchFieldText, onEditingChanged: { focused in
                        if (viewModel.searchFieldText == "") {
                            viewModel.mapView.removeOverlays(viewModel.mapView.overlays)
                            viewModel.mapView.removeAnnotations(viewModel.mapView.annotations)
                        }
                    })
                        .padding()
                        .background(Color.white)
                    Image(systemName: "magnifyingglass")
                        .padding()
                        .padding(2.5)
                        .background(Color.white)
                }

                VStack {
                    Spacer()
                    
                    Button(action: {
                        shouldSignOut = true
                        UserDefaults.standard.set(false, forKey: "isUserLoggedin")
                    },
                    label: {
                        Image("powerOff")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.title2)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(Circle())
                            .frame(width: 80, height: 80)
                    })

                    Button(action: { shouldDisplayHistoryScreen = true },
                           label: {
                            Image("historyIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.title2)
                                .padding(20)
                                .background(Color.white)
                                .clipShape(Circle())
                                .frame(width: 80, height: 80)
                           })

                    Button(action: { focusOnCurrentUserLocation() },
                           label: {
                            Image("gpsIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.title2)
                                .padding(20)
                                .background(Color.white)
                                .clipShape(Circle())
                                .frame(width: 80, height: 80)
                           })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }

            VStack {
                    ScrollView {
                        if (!viewModel.locations.isEmpty
                                && viewModel.searchFieldText != "") {
                            ForEach(viewModel.locations){ location in
                                Text(location.location.name ?? "")
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        if let coordinate = location.location.location?.coordinate {
                                        viewModel.drawPinAndPathForSelectionLocation(location:coordinate, name: location.location.name ?? "")
                                        }
                                    }
                                Divider()
                                }
                        } else if (viewModel.searchResultsError != nil
                                    && viewModel.searchFieldText != ""
                                    && viewModel.shouldShowNoResultsFound) {
                            Text("No results found...")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .top)
                                .background(Color.white)
                            Divider()
                        }
                    }
                    .background(Color.white)
            }
            .offset(y: 50)
            
            if (shouldSignOut) {
                ContentView()
            }

            if (shouldDisplayHistoryScreen) {
                ZStack() {
                    VStack {
                        Text("Search History")
                            .bold()
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color.black)
                            .padding(.top, 30)
                        List {
                            let savedLocations = viewModel.dataManager.getSavedLocations()
                            if (savedLocations != []) {
                                ForEach(savedLocations){ location in
                                    Text(location.name ?? "")
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onTapGesture {
                                            let Coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.lognitude)
                                            viewModel.drawPinAndPathForSelectionLocation(location: Coordinate, name:location.name ?? "", isFromHistoryView: true)
                                            shouldDisplayHistoryScreen = false
                                        }
                                }
                            }
                        }
                        .background(Color.red)
                        .ignoresSafeArea()
                    }
                    .background(Color.white)
                    .ignoresSafeArea()
                    
                    VStack{
                        Spacer()

                        Button(action: {
                            shouldDisplayHistoryScreen = false
                            shouldSignOut = true
                            UserDefaults.standard.set(false, forKey: "isUserLoggedin")
                        },
                        label: {
                            Image("powerOff")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.title2)
                                .padding(20)
                                .background(Color.white)
                                .clipShape(Circle())
                                .frame(width: 80, height: 80)
                        })

                        Button(action: { shouldDisplayHistoryScreen = false },
                               label: {
                                Image(systemName: "xmark")
                                    .aspectRatio(contentMode: .fit)
                                    .font(.title2)
                                    .padding(20)
                                    .background(Color.white)
                                    .clipShape(Circle())
                               })
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }

        }
        .onAppear(perform: {
            locationManager.delegate = viewModel
            if (locationManager.authorizationStatus == .authorizedAlways
                    || locationManager.authorizationStatus == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
                return
            }
                locationManager.requestWhenInUseAuthorization()
        })
        .alert(isPresented: $viewModel.permissionDenied, content: {
            createPermissionDeniedAlert()
        })
        .alert(isPresented: $viewModel.directionsNotFoundError, content: {
            createNoDriectionsFoundAlert()
        })
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: viewModel.searchFieldText, perform: { value in
            if (viewModel.searchFieldText == "") {
                viewModel.mapView.removeAnnotations(viewModel.mapView.annotations)
                viewModel.mapView.removeOverlays(viewModel.mapView.overlays)
            }
            let delay = 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                if value == viewModel.searchFieldText {
                    viewModel.searchLocations()
                }
            })
        })
    }

    fileprivate func focusOnCurrentUserLocation() {
        guard let region = viewModel.region  else { return }
        
        viewModel.mapView.setRegion(region, animated: true)
        viewModel.mapView.setVisibleMapRect(viewModel.mapView.visibleMapRect, animated: true)
    }

    fileprivate func createPermissionDeniedAlert() -> Alert {
        return Alert(title: Text("Permission Denied"),
                     message: Text("Please Enable Permission In App Setting"),
                     dismissButton: .default(Text("Goto Settings"), action: {
                        // Redirect to device settings.
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                     }))
    }

    fileprivate func createNoDriectionsFoundAlert() -> Alert {
        return Alert(title: Text("Directions could not be found.."),
                 message: Text("Please try other nearby locations"),
                 dismissButton: .default(Text("Ok"), action: {
                    viewModel.directionsNotFoundError = false
                 }))
    }

}

struct SearchLocationsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchLocationsScreen()
    }
}
