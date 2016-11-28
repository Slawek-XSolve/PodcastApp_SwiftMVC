//
//  PodcastListViewController.swift
//  PodcastApp_SwiftMVC
//
//  Created by Slawomir Zagorski on 22.11.2016.
//  Copyright © 2016 SZ. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate var dataSource: PodcastDataSource?
    fileprivate var delayedSearch: Bool = false

    fileprivate let reuseIdentifier = "PodcastCell"
    fileprivate let podcastDetailSegueName = "PodcastDetailSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = PodcastDataSource(changeCallback: { [weak self] in self?.sourceChangeCallback() }, progressChangeCallback: { [weak self] (isWorking) in self?.sourceProgressChangeCallback(isWorking) })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == podcastDetailSegueName, let indexPath = collectionView.indexPath(for: sender as! PodcastCollectionViewCell) else {
            return
        }
        (segue.destination as! PodcastViewController).configure(withPodcast: dataSource![indexPath.row])
    }

}

extension PodcastListViewController {

    fileprivate func sourceChangeCallback() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    fileprivate func sourceProgressChangeCallback(_ isWorking: Bool) {
        DispatchQueue.main.async {
            if (isWorking) {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }

}

extension PodcastListViewController : UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !delayedSearch else {
            return
        }
        let deadline =  DispatchTime.now() + .milliseconds(300)

        delayedSearch = true
        DispatchQueue.global().asyncAfter(deadline: deadline, execute: { [weak self] in
            self?.updateDataSourceSearchTerm()
        })
    }

    fileprivate func updateDataSourceSearchTerm() {
        guard delayedSearch else {
            return
        }
        delayedSearch = false

        guard let searchTerm = searchBar.text else {
            return
        }
        dataSource!.searchTerm = searchTerm
    }

}

extension PodcastListViewController : UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.count;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PodcastCollectionViewCell
        let podcast = dataSource![indexPath.row]

        if let imageURL = podcast.artworkURL {
            cell.imageView.sd_setImage(with: imageURL)
        } else {
            cell.imageView.image = nil
        }
        cell.label?.text = podcast.trackName

        return cell
    }

}
