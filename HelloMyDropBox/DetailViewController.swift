//
//  DetailViewController.swift
//  HelloMyDropBox
//
//  Created by 徐志豪 on 2018/12/19.
//  Copyright © 2018 orange. All rights reserved.
//

import UIKit

import SwiftyDropbox
class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var mainimageview: UIImageView!
    
    func configureView() {
        // Update the user interface for the detail item.
//        if let detail = detailItem {
//            if let label = detailDescriptionLabel {
//                label.text = detail.description
//            }
//        }
        guard let file = detailItem,
            let  imageView = mainimageview else{
                return
        }
        
        let path = "/\(file.name)"
        DropboxManager.shared.downllooadFile(at: path){
            (response,error) in
            if let error = error{
                print("error")
                return
            }
            guard let (metadata , data) = response else{return}
            
            imageView.image = UIImage(data: data)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: Files.Metadata? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

