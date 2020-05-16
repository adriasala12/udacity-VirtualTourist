//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Adrià Sala Roget on 12/05/2020.
//  Copyright © 2020 Adrià Sala Roget. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController {
    
    // MARK: Properties and Overriden Methods
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var container: NSPersistentContainer!
    var selectedPin: Pin!
    var coordinate: CLLocationCoordinate2D!
    var pictures = [Picture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        newCollectionButton.isEnabled = false
        
        configureMapView()
        
        // If there are pictures in context, loads collection
        // If there are no pictures, calls getPictureUrls()
        fetchPictures()
    }
    
    deinit {
        self.removeFromParent()
    }
    
    // MARK: - New Collection
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        for picture in pictures {
            container.viewContext.delete(picture)
            do {
                try container.viewContext.save()
            } catch {
                print(error)
            }
        }
        pictures.removeAll()
        fetchPictures()
    }
    
    // MARK: - Fetching Pictures
    
    fileprivate func fetchPictures() {
        let fetchRequest: NSFetchRequest<Picture> = Picture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", argumentArray: [selectedPin!])
        
        do {
            pictures = try container.viewContext.fetch(fetchRequest)
            print("Fetched pictures: ")
            print(pictures)
        } catch {
            print(error)
        }
        
        if pictures.count > 0 {
            collectionView.reloadData()
        } else {
            getPictureUrls()
        }
    }
    
    fileprivate func getPictureUrls() {
        Client.getFlickrUrls(latitude: coordinate.latitude, longitude: coordinate.longitude, completion: {photoInfo in
            
            for photo in photoInfo {
                let picture = Picture(context: self.container.viewContext)
                picture.pin = self.selectedPin
                picture.urlString = String("https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")
                
                let url = URL(string: picture.urlString!)!
                
                Client.getFlickrImageData(forUrl: url, completion: {data in
                    
                    picture.data = data
                    
                    do {
                        try self.container.viewContext.save()
                        DispatchQueue.main.async {
                            self.pictures.append(picture)
                            self.collectionView.reloadData()
                        }
                        
                    } catch {
                        print(error)
                    }
                })
            }
        })
    }
    
    // MARK: - MapView Setup
    
    fileprivate func configureMapView() {
        mapView.isUserInteractionEnabled = false
        
        // Setup Region
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        // Setup Annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView.pinTintColor = .red
        pinView.canShowCallout = false
        mapView.addAnnotation(annotation)
        mapView.addSubview(pinView)
    }
}


extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Collection Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count = pictures.count
        if count == 0 { label.isHidden = false } else { label.isHidden = true}
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let picture = pictures[indexPath.row]
        if let data = picture.data {
            cell.imageView.image = UIImage(data: data)
        } else {
            cell.imageView.image = UIImage(named: "placeholder")
            print("placeholder")
        }
        
        if indexPath.row == indexPath.last {
            newCollectionButton.isEnabled = true
        }
        
        return cell
    }
    
    // MARK: - Collection Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let picture = pictures[indexPath.row]
        container.viewContext.delete(picture)
        pictures.remove(at: indexPath.row)
        collectionView.reloadData()
        
        do {
            try container.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - Collection Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.width
        var cellWidth = (totalWidth - 6 * 2)/3
        cellWidth.round(.down)
        let size = CGSize(width: cellWidth, height: cellWidth)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
}



