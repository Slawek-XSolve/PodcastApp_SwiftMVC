//
//  PodcastDataSource.swift
//  PodcastApp_SwiftMVC
//
//  Created by Slawomir Zagorski on 23.11.2016.
//  Copyright © 2016 SZ. All rights reserved.
//

import Foundation 

class PodcastDataSource {
    fileprivate let progressChangeCallback: (Bool) -> ()
    fileprivate let changeCallback: () -> ()
    fileprivate var podcasts: Array<PodcastModel> = [] {
        didSet {
            changeCallback()
        }
    }
    var working: Bool = false {
        didSet(previousVal) {
            guard previousVal != working else {
                return
            }
            progressChangeCallback(working)
        }
    }
    fileprivate var currentSearchTerm: String = ""
    var searchTerm: String = "" {
        didSet(previousSearchTerm) {
            guard previousSearchTerm != searchTerm && currentSearchTerm != searchTerm else {
                return
            }
            reloadPodcasts()
        }
    }
    var count: Int {
        return podcasts.count
    }
    fileprivate let itunesAPI: String = "https://itunes.apple.com/search"
    fileprivate let itemLimit: Int = 50
    fileprivate var currentDataTask: URLSessionDataTask?

    init(changeCallback: @escaping () -> (), progressChangeCallback: @escaping (Bool) -> ()) {
        self.changeCallback = changeCallback
        self.progressChangeCallback = progressChangeCallback
    }

    subscript(index: Int) -> PodcastModel {
        get {
            return podcasts[index]
        }
    }

}

extension PodcastDataSource {

    fileprivate var urlSession: URLSession {
        return URLSession.shared
    }

    fileprivate func apiURL(searchTerm: String) -> URL {
        let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        return URL(string: "\(itunesAPI)?limit=\(itemLimit)&term=\(encodedSearchTerm)")!
    }

    fileprivate func reloadPodcasts() {
        if currentDataTask != nil {
            currentDataTask!.cancel()
            currentDataTask = nil
        }
        guard searchTerm != "" else {
            podcasts = []
            working = false

            return
        }
        let searchedTerm = searchTerm

        currentDataTask = urlSession.dataTask(with: apiURL(searchTerm: searchTerm)) { [weak self] (data, _, error) in
            guard let `self` = self else {
                return
            }
            guard data != nil && (error == nil || (error as? NSError)?.code == NSURLErrorCancelled) else {
                self.podcasts = []
                self.currentSearchTerm = ""
                self.working = false

                return
            }
            guard let responseModel = APIResponeModel(data: data!) else {
                self.podcasts = []
                self.currentSearchTerm = ""
                self.working = false

                return
            }
            self.podcasts = responseModel.results
            self.currentSearchTerm = searchedTerm
            self.working = false
        }
        working = true
        currentDataTask!.resume()
    }

}
