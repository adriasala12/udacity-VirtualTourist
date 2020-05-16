//
//  TouristMapViewController.swift
//  VirtualTourist
//
//  Created by Adrià Sala Roget on 12/05/2020.
//  Copyright © 2020 Adrià Sala Roget. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TouristMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    var container: NSPersistentContainer = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer
    
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setRegion()
        loadAnnotations()
        addGesture()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAnnotations()
    }
    
    // MARK: - Region Persistence
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        UserDefaults.standard.setValue(mapView.region.center.latitude as Double, forKey: "latitude")
        UserDefaults.standard.setValue(mapView.region.center.longitude as Double, forKey: "longitude")
        UserDefaults.standard.setValue(mapView.region.span.latitudeDelta as Double, forKey: "latDelta")
        UserDefaults.standard.setValue(mapView.region.span.longitudeDelta as Double, forKey: "lonDelta")
    }
    
    fileprivate func setRegion() {
        if  let lat = UserDefaults.standard.value(forKey: "latitude") as? CLLocationDegrees,
            let lon = UserDefaults.standard.value(forKey: "longitude") as? CLLocationDegrees,
            let latDelta = UserDefaults.standard.value(forKey: "latDelta") as? CLLocationDegrees,
            let lonDelta = UserDefaults.standard.value(forKey: "lonDelta") as? CLLocationDegrees
        {
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }
    
    // MARK: - Load Persisted Annotations
    fileprivate func loadAnnotations() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            var annotations = [MKPointAnnotation]()
            for result in results {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
                annotations.append(annotation)
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(annotations)
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Add Pin Functionality
    
    fileprivate func addGesture() {
        let gestureRecognizer = UILongPressGestureRecognizer()
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.addTarget(self, action: #selector(addPin(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func addPin(_ gestureRecongizer: UIGestureRecognizer) {
        if gestureRecongizer.state == UIGestureRecognizer.State.began {
            // Obtain the coordinates
            let location = gestureRecongizer.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            // Adding new annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
            
            // Creating and saving new Pin object
            let pin = Pin(context: container.viewContext)
            pin.latitude = coordinates.latitude as Double
            pin.longitude = coordinates.longitude as Double
            do {
                try container.viewContext.save()
                print("New pin successfully added and saved")
            } catch  {
                print(error)
            }
        }
        gestureRecongizer.isEnabled = false
        gestureRecongizer.isEnabled = true
    }
    
    // MARK: - Delegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView?.canShowCallout = false
            pinView?.tintColor = .red
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.setSelected(false, animated: true)
        var selectedPin = Pin(context: container.viewContext)
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            
            for result in results {
                if result.latitude == view.annotation!.coordinate.latitude, result.longitude == view.annotation!.coordinate.longitude {
                    selectedPin = result
                    break
                }
            }
        } catch {
            print(error)
        }
        
        performSegue(withIdentifier: "segue", sender: selectedPin)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CollectionViewController
        destination.container = container
        let pin = sender as! Pin
        destination.selectedPin = pin
        destination.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }

}
