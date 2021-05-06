//
//  SearchLocationsScreen.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 06/05/21.
//

import SwiftUI
import CoreLocation

struct SearchLocationsScreen: View {
    @StateObject var viewModel = MapViewModel()

    @State var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack{
            MapView()
                .environmentObject(viewModel)
                .ignoresSafeArea(.all, edges: .all)
            VStack {
                HStack(spacing: 0) {
                    TextField("Search", text: $viewModel.searchFieldText)
                        .padding()
                        .background(Color.white)
                    Image(systemName: "magnifyingglass")
                        .padding()
                        .padding(2.5)
                        .background(Color.white)
                }

                VStack {
                    Spacer()
                    
                    Button(action: { focusOnCurrentUserLocation() },
                           label: {
                            Image(systemName: "location.fill")
                                .aspectRatio(contentMode: .fit)
                                .font(.title2)
                                .padding(20)
                                .background(Color.primary)
                                .clipShape(Circle())
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
                                        viewModel.drawPinAndPathForSelectionLocation(location: location)
                                    }
                                
                                Divider()
                            }
                        } else if (viewModel.searchResultsError != nil
                                    && viewModel.searchFieldText != ""
                                    && !viewModel.didRenderPinAndPath) {
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
        }
        .onAppear(perform: {
            locationManager.delegate = viewModel
            locationManager.requestWhenInUseAuthorization()
        })
        .alert(isPresented: $viewModel.permissionDenied, content: {
            createPermissionDeniedAlert()
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

}

struct SearchLocationsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchLocationsScreen()
    }
}
