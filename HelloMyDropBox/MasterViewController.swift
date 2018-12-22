//
//  MasterViewController.swift
//  HelloMyDropBox
//
//  Created by 徐志豪 on 2018/12/19.
//  Copyright © 2018 orange. All rights reserved.
//

import UIKit
import SwiftyDropbox
class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Files.Metadata]()

    
    let manager = DropboxManager.shared
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        //1)
        manager.handlePergormLinkResult { (result) in
            
            // 13)
            switch result {
            case .success(let token):
                self.downloadFileList()
                print("login OK\(token)")
            case .error(let error,let description):
                
                print("login error\(error)\(description)")
            case .cancel:
                
                print("login cancel")
               
            }
            // 14)
        }
        
        //3)
        if manager.isLinked(){
            //diwnload file list
            downloadFileList()
        }else{
            //perform Login
            manager.performLink(from: self)
            //6)
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func downloadFileList(){
        print("downloadfilelist start")
        manager.downloadFileList { (
            response,error) in
            if let error = error{
                print("downloadFileList error\(error)")
                return
            }
            if let response = response{
                 print("downloadFileList,total\(response.entries.count)files.")
                self.objects = response.entries
                
                self.tableView.reloadData()
            }
        }
    }

    @objc
    func insertNewObject(_ sender: Any) {
        guard let url = Bundle.main.url(forResource: "jobs_monkey.jpg", withExtension: nil)else{
            assertionFailure("fail")
            return}
        
        let path = "/\(Data().description).jpg"
        manager.uploadFile(url: url, fullFilePathname: path){
            (metadata,error) in
            if let error = error{
                print("Upload error\(error)")
                return
            }
            if let metadata = metadata{
                
                print("UPload OK\(metadata.name)")
                self.downloadFileList()
            }
            
        }
        
        
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let file = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = file
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let file = objects[indexPath.row]
        cell.textLabel!.text = file.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let file = objects[indexPath.row]
            let fullFilepathname = "/\(file.name)"
            
            manager.deleteFile(at: fullFilepathname) { (result,error)
                in
                if let error = error{
                    print("Delete error\(error)")
                    return
                }else{
                    print("Delete OK")
                    self.downloadFileList()
                    
                }
                
                
            }
            
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            
        } else if editingStyle == .insert {
         
            
        }
    }


}

