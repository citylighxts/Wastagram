import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @Published var userAddress: String?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func requestLocation() { locationManager?.requestLocation() }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager?.authorizationStatus == .authorizedWhenInUse {
            locationManager?.requestLocation()
        } else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.getAddressFromLatLon(pdblLatitude: location.coordinate.latitude, withLongitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { print(error.localizedDescription) }
    
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude: Double) {
        let ceo = CLGeocoder()
        let loc = CLLocation(latitude: pdblLatitude, longitude: withLongitude)
        ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
            if let pm = placemarks?.first {
                var addressString = ""
                if let thoroughfare = pm.thoroughfare { addressString += thoroughfare + ", " }
                if let subLocality = pm.subLocality { addressString += subLocality + ", " }
                if let locality = pm.locality { addressString += locality }
                self.userAddress = addressString
            }
        }
    }
}
