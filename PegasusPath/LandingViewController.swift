//
//  LandingViewController.swift
//  PegasusPath
//
//  Created by Isaias Perez on 4/18/18.
//  Copyright © 2018 Christopher Donoso. All rights reserved.
//
import UIKit
import Foundation

class LandingViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollViewControl: UIScrollView!

    
    var contentWidth:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewControl.delegate = self
        
        for image in 0...4 {
            let imageDisplaying = UIImage(named: "\(image).png")
            let imageView = UIImageView(image: imageDisplaying)
            
            let xCoordinate = view.frame.midX + view.frame.width * CGFloat(image)
            contentWidth += view.frame.width
            scrollViewControl.addSubview(imageView)
            imageView.frame = CGRect(x: xCoordinate - 175, y: (view.frame.height / 4) - 200, width:350, height: 350)
        }
        
        scrollViewControl.contentSize = CGSize(width: contentWidth, height: view.frame.height)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGFloat(375))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func SignInButton(_ sender: Any) {
         performSegue(withIdentifier: "goLogIn", sender: self)
    }
    
    @IBAction func SignUpButton(_ sender: Any) {
        performSegue(withIdentifier: "goSignUp", sender: self)
    }
    
    
}
