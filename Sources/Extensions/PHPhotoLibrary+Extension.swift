//
//  PHPhotoLibrary+Extension.swift
//
//  https://gist.github.com/w-i-n-s/9d15ec7beff3fead6b041c687ef00c90
//  Created by 10-N3344 on 7/1/24.
//

import UIKit
import Photos

public extension PHPhotoLibrary {

    // MARK: - Public
    func saveVideo(fileUrl: URL, albumName: String =  CommonUtils.getAppName, completion: @escaping ((Bool) -> Void)) {
        if let album = PHPhotoLibrary.shared().findAlbum(albumName: albumName) {
            self.saveVideo(fileUrl: fileUrl, album: album, completion: completion)
        } else {
            PHPhotoLibrary.shared().createAlbum(albumName: albumName, completion: { (collection) in
                if let collection = collection {
                    self.saveVideo(fileUrl: fileUrl, album: collection, completion: completion)
                } else {
                    completion(false)
                }
            })
        }
    }

    func savePhoto(fileUrl: URL, albumName: String = CommonUtils.getAppName, completion: @escaping ((Bool) -> Void)) {
        if let album = PHPhotoLibrary.shared().findAlbum(albumName: albumName) {
            self.saveUrlToImage(fileUrl: fileUrl, album: album, completion: completion)
        } else {
            PHPhotoLibrary.shared().createAlbum(albumName: albumName, completion: { (collection) in
                if let collection = collection {
                    self.saveUrlToImage(fileUrl: fileUrl, album: collection, completion: completion)
                } else {
                    completion(false)
                }
            })
        }
    }

    func savePhoto(image: UIImage, albumName: String = CommonUtils.getAppName, completion: @escaping ((Bool) -> Void)) {
        if let album = PHPhotoLibrary.shared().findAlbum(albumName: albumName) {
            self.saveImage(image: image, album: album, completion: completion)
        } else {
            PHPhotoLibrary.shared().createAlbum(albumName: albumName, completion: { (collection) in
                if let collection = collection {
                    self.saveImage(image: image, album: collection, completion: completion)
                } else {
                    completion(false)
                }
            })
        }
    }
    
    fileprivate func saveVideo(fileUrl: URL, album: PHAssetCollection, completion: @escaping ((Bool) -> Void)) {

        PHPhotoLibrary.shared().performChanges ({

            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                  let photoPlaceholder = createAssetRequest?.placeholderForCreatedAsset else {
                completion(false)
                return
            }
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)

        }, completionHandler: { success, error in
            if success == true && error == nil {
                completion(true)
            } else {
                DebugLog("Error saving video: \(error!.localizedDescription)")
                completion(false)
            }
        })
    }

    fileprivate func saveUrlToImage(fileUrl: URL, album: PHAssetCollection, completion: @escaping ((Bool) -> Void)) {

        PHPhotoLibrary.shared().performChanges ({

            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                  let photoPlaceholder = createAssetRequest?.placeholderForCreatedAsset else {
                completion(false)
                return
            }
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)

        }, completionHandler: { success, error in
            if success == true && error == nil {
                completion(true)
            } else {
                DebugLog("Error saving image: \(error!.localizedDescription)")
                completion(false)
            }
        })
    }

    fileprivate func saveImage(image: UIImage, album: PHAssetCollection, completion: @escaping ((Bool) -> Void)) {

        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                  let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                completion(false)
                return
            }
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
        }, completionHandler: { success, error in
            if success == true && error == nil {
                completion(true)
            } else {
                DebugLog("Error saving image: \(error!.localizedDescription)")
                completion(false)
            }
        })
    }


    // MARK: - Private
    fileprivate func findAlbum(albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }

    fileprivate func createAlbum(albumName: String, completion: @escaping (PHAssetCollection?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    completion(nil)
                    return
                }
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                completion(album)
            } else {
                completion(nil)
            }
        })
    }
}
