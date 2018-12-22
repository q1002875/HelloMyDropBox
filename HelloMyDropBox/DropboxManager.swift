//
//  DropboxManager.swift
//  HelloMyDropBox
//
//  Created by 徐志豪 on 2018/12/19.
//  Copyright © 2018 orange. All rights reserved.
//

import Foundation
import SwiftyDropbox
typealias LinkResultHandler = (DropboxOAuthResult) ->Void
typealias DownloadListResultHandler = (Files.ListFolderResult?, CallError<Files.ListFolderError>?) -> Void

typealias FileUploadResultHandler = (Files.FileMetadata?, CallError<Files.UploadError>?) ->Void

typealias FileDeleteResulthandler = (Files.DeleteResult?, CallError<Files.DeleteError>?) -> Void

typealias DownloadFileHandler = ((Files.FileMetadata, Data)?, CallError<Files.DownloadError>?) -> Void
class  DropboxManager{
    
    private var linkResulHandler:LinkResultHandler?
    
    //singeton 單例模式
    //Design Pattern 設計模式
    static let shared = DropboxManager()
    
    //private外面不能創造shared
    private init(){
    
    }
    //設定key
    func setup(appKey:String){
        DropboxClientsManager.setupWithAppKey(appKey)
        
    }
    //2)
    func handlePergormLinkResult(_ handler:LinkResultHandler?){
        
        return linkResulHandler = handler
    }
    
    func isLinked() ->Bool{
        return DropboxClientsManager.authorizedClient != nil
    }
    
    //4)
    func performLink(from:UIViewController){
        
        //7)
        //調整main執行緒的順序晚點執行
        DispatchQueue.main.async {
            DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: from) { (url) in
                //9)
               // 會有個url來呼叫自己的UIApplication
                UIApplication.shared.open(url, options: [:])
                // 16)
            }
            //8)

        }
        //5)
    }
    
    
    func handleLinkResult(url:URL) ->Bool{
        // 11)
        guard let result = DropboxClientsManager.handleRedirectURL(url) else {
            assertionFailure("Invalid link result")
            return false
        }
        // 12)
        linkResulHandler?(result)
        return true
        // 15)
    }
    
    //下載
    func downloadFileList(handler: @escaping DownloadListResultHandler){
        guard let client = DropboxClientsManager.authorizedClient else{
            assertionFailure("Need to link first")
         return
        }
        client.files.listFolder(path: "").response(completionHandler:handler)
    }
    
    //上傳
    func uploadFile(url:URL,fullFilePathname:String,handler:@escaping FileUploadResultHandler){
        //檢查連線
        guard let client = DropboxClientsManager.authorizedClient else{
            assertionFailure("Need to link first")
            return
        }
        client.files.upload(path: fullFilePathname, input: url).response(completionHandler:handler)

    }
    //刪除
    func deleteFile(at fullFilePathname:String,handler:@escaping FileDeleteResulthandler){
        guard let client = DropboxClientsManager.authorizedClient else{
            assertionFailure("Need to link first")
            return
        }
        
        client.files.deleteV2(path: fullFilePathname).response(completionHandler: handler)
        
        
        
    }
    
    func downllooadFile(at fullFilePathname:String,handler:@escaping DownloadFileHandler){
        guard let client = DropboxClientsManager.authorizedClient else{
        assertionFailure("Need to link first")
        return
        }
//        client.files.download(path: fullFilePathname).response(completionHandler: handler)
        
    client.files.download(path: fullFilePathname).response(completionHandler: handler)
    
    
    }
        
        
    
    
    
    
    
    
}
