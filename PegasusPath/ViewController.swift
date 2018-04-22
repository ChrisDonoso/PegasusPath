//
//  ViewController.swift
//  PegasusPath
//
//  Created by Christopher Donoso on 2/21/18.
//  Copyright © 2018 Christopher Donoso. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxGeocoder
import Firebase

class ViewController: UIViewController, MGLMapViewDelegate {
    
    private var ucf: MGLCoordinateBounds!
    var nameEvent:String!
    var descriptionEvent:String!
    var mapView: NavigationMapView!
    var coordinate: CLLocationCoordinate2D!
    var point: CGPoint!
    var directionsRoute: Route?
    var db: Firestore!
    var likeCounter = 0;
    var dbCoordinate: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Receives name from the user from pop up UI
        NotificationCenter.default.addObserver(forName: .saveNameField, object: nil, queue: OperationQueue.main) { (notification) in
            let nameVc = notification.object as! PopUpViewController
            self.nameEvent = nameVc.nameField.text
            
            self.addEvent(coordinate: self.coordinate)
            self.drawObstacles()
        }
        
//        //Receives description from the user from pop up UI and draws obstacles
//        NotificationCenter.default.addObserver(forName: .saveDescriptionField, object: nil, queue: OperationQueue.main) { (notification) in
//            let nameVc = notification.object as! PopUpViewController
//            self.descriptionEvent = nameVc.descriptionField.text
//
//            //Stores the marker to the database and places it on the map
//            self.addEvent(coordinate: self.coordinate)
//            self.drawObstacles()
//        }
        
        //Receives like from the user.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "like"), object: nil, queue: OperationQueue.main) { (notification) in
            
            self.addRating(coordinate: self.dbCoordinate, rating: "like")
            self.viewDidLoad()
        }

        //Receives dislike from the user.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "dislike"), object: nil, queue: OperationQueue.main) { (notification) in
            
            self.addRating(coordinate: self.dbCoordinate, rating: "dislike")
            self.viewDidLoad()
        }
        
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
//
//        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        
        
        
        mapView = NavigationMapView(frame: view.bounds)
        view.addSubview(mapView)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        // UCF, Orlando, Florida
        let center = CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001)
        
        // Starting point
        mapView.setCenter(center, zoomLevel: 14, direction: 0, animated: false)
        
        // UCF's bounds
        let ne = CLLocationCoordinate2D(latitude: 28.6345, longitude: -81.17340)
        let sw = CLLocationCoordinate2D(latitude: 28.5820, longitude: -81.2241)
        ucf = MGLCoordinateBounds(sw: sw, ne: ne)
        
        //Alow the map to display the user's location
        mapView.showsUserLocation = true
        
        //Add a gesture recognizer to the map view
        let setDestination = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(setDestination)
        
        //Acquires and draws the obstacles from the database
        drawObstacles()
        
    }
    
    // Restricts the camera movement.
    func mapView(_ mapView: MGLMapView, shouldChangeFrom oldCamera: MGLMapCamera, to newCamera: MGLMapCamera) -> Bool {
        
        // Get the current camera to restore it after.
        let currentCamera = mapView.camera
        
        // From the new camera obtain the center to test if it’s inside the boundaries.
        let newCameraCenter = newCamera.centerCoordinate
        
        // Set the map’s visible bounds to newCamera.
        mapView.camera = newCamera
        let newVisibleCoordinates = mapView.visibleCoordinateBounds
        
        // Revert the camera.
        mapView.camera = currentCamera
        
        // Test if the newCameraCenter and newVisibleCoordinates are inside self.ucf.
        let inside = MGLCoordinateInCoordinateBounds(newCameraCenter, self.ucf)
        let intersects = MGLCoordinateInCoordinateBounds(newVisibleCoordinates.ne, self.ucf) && MGLCoordinateInCoordinateBounds(newVisibleCoordinates.sw, self.ucf)
        
        return inside && intersects
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        //Calls the pop up UI
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpID") as! PopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)

        // Converts point where user did a long press to map coordinates
        point = sender.location(in: mapView)
        coordinate = mapView.convert(point, toCoordinateFrom: mapView)

    }
    
    // Implement the delegate method that allows annotations to show callouts when tapped
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        dbCoordinate = annotation.coordinate
        return true
    }
    
    // Present the navigation view controller when the callout is selected
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {

        //Calls the rating UI
        let ratingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ratingID") as! RatingViewController
        self.addChildViewController(ratingVC)
        ratingVC.view.frame = self.view.frame
        self.view.addSubview(ratingVC.view)
        ratingVC.didMove(toParentViewController: self)
    }
    
    //Stores the marker to the database
    private func addEvent(coordinate: CLLocationCoordinate2D){
        
        // [START addEvent]
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("events").addDocument(data: [
            "name": nameEvent,
            //"description": descriptionEvent,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "like": 1,
            "dislike": 0
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        // [END add_ada_lovelace]
    }
    
    //Displays the markers from the database to the map
    private func drawObstacles() {
        
        // [START get_multiple_all]
        db.collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    var latitude:Any = 0
                    var longitude:Any = 0
                    var likeCount: Int = 0
                    var dislikeCount:Int = 0
                    var totalCount:Double = 0
                    var rating:Double = 0
                    var name:String?
                    //var description:String?
                    
                    print("\(document.documentID) => \(document.data())")
                    
                    //Finds the longitude, latitude, description, and name
                    for field in document.data(){

                        if field.key == "latitude"{
                            latitude = field.value
                        }
                        
                        if field.key == "longitude"{
                            longitude = field.value
                        }
                        
//                        if field.key == "description"{
//                            description = field.value as? String
//                        }
                        
                        if field.key == "name"{
                            name = field.value as? String
                        }
                        
                        if field.key == "like"{
                            likeCount = (field.value as? Int)!
                        }
                        
                        if field.key == "dislike"{
                            dislikeCount = (field.value as? Int)!
                        }
                        
                    }
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                    
                    totalCount = Double(likeCount + dislikeCount)
                    rating = (Double(likeCount) / totalCount) * 100
         
                    // Create a basic point annotation and add it to the map
                    let annotation = MGLPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = name
                    annotation.subtitle = String(format: "%.2f", rating) + "%"
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    private func deleteObstacle() {
        
        // [START get_multiple_all]
        db.collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) => \(document.data())")
                    
                    //Finds the longitude, latitude, description, and name
                    for field in document.data(){
                        
                        //If the obstacle selected by the user is found it will acquire
                        //the necessary information to update the dislike rating.
                        if field.key == "dislike" {
                            if field.value as! Int > 4 {
                                self.db.collection("events").document(document.documentID).delete() { err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                    } else {
                                        print("Document successfully removed!")
                                        self.viewDidLoad()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Updates the like/dislike value in the database.
    private func addRating(coordinate: CLLocationCoordinate2D, rating: String) {
        
        // [START get_multiple_all]
        db.collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let latitude = coordinate.latitude
                    let longitude = coordinate.longitude
                    var count = 0
                    var updateLike = 0
                    var updateDislike = 0
                    var tempDocument:String!

                    print("\(document.documentID) => \(document.data())")
                    
                    //Finds the longitude, latitude, description, and name
                    for field in document.data(){
                        
                        //Checks if the obstacle's latitude selected by the user
                        //is found in the database.
                        if field.key == "latitude"{
                            let tempValue = field.value as! Double
                            
                            if tempValue == Double(latitude){
                                count = count + 1
                            }
                        }
                        
                        //Checks if the obstacle's longitude selected by the user
                        //is found in the database.
                        if field.key == "longitude"{
                            let tempValue = field.value as! Double
                            
                            if tempValue == Double(longitude){
                                count = count + 1
                            }
                        }
                        
                        //If the obstacle selected by the user is found it will acquire
                        //the necessary information to update the like rating.
                        if count == 2 && field.key == "like" {
                            let tempValue = field.value as! Int
                            
                            tempDocument = document.documentID
                            updateLike = tempValue
                        }
  
                        //If the obstacle selected by the user is found it will acquire
                        //the necessary information to update the dislike rating.
                        if count == 2 && field.key == "dislike" {
                            let tempValue = field.value as! Int
                            
                            tempDocument = document.documentID
                            updateDislike = tempValue
                        }
                    }
                    
                    //Add like rating to the database
                    if count == 2 && rating == "like"{
                        //Add like to db
                        
                        let ratingRef = self.db.collection("events").document(tempDocument)

                        ratingRef.updateData([
                            "like": updateLike + 1
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                    
                    //Add dislike rating to the database
                    if count == 2 && rating == "dislike"{
                        let ratingRef = self.db.collection("events").document(tempDocument)
                        
                        ratingRef.updateData([
                            "dislike": updateDislike + 1
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                            self.drawObstacles()
                        }
                    }
                }
            }
        }
    }
}
