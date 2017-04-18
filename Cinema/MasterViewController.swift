//
//  MasterViewController.swift
//  Cinema
//
//  Created by Martin Bauer on 17.04.17.
//  Copyright © 2017 Martin Bauer. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {

  let library = SampleLibrary()
  var mediaItems = [MediaItem]()
  var filteredMediaItems = [MediaItem]()

  var detailViewController: DetailViewController? = nil
  let searchController: UISearchController = UISearchController(searchResultsController: nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    if let split = splitViewController {
      let controllers = split.viewControllers
      detailViewController = (controllers[
          controllers.count - 1
          ] as! UINavigationController).topViewController as? DetailViewController
    }
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
    mediaItems = library.mediaItems(where: { _ in true })
    mediaItems.sort { (left, right) in
      if left.title != right.title {
        return left.title < right.title
      } else {
        return left.year < right.year
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let selectedItem: MediaItem
        if (searchController.isActive && searchController.searchBar.text != "") {
          selectedItem = filteredMediaItems[indexPath.row]
        } else {
          selectedItem = mediaItems[indexPath.row]
        }
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = selectedItem
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
    if (searchController.isActive && searchController.searchBar.text != "") {
      return filteredMediaItems.count
    } else {
      return mediaItems.count
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyTableCell

    let mediaItem: MediaItem
    if (searchController.isActive && searchController.searchBar.text != "") {
      mediaItem = filteredMediaItems[indexPath.row]
    } else {
      mediaItem = mediaItems[indexPath.row]
    }
    cell.titleLabel!.text = Utils.fullTitle(of: mediaItem)
    cell.runtimeLabel!.text = Utils.formatDuration(mediaItem.runtime)

    return cell
  }

  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55
  }

  func filterContentForSearchText(searchText: String) {
    let lowercasedSearchText = searchText.lowercased()
    filteredMediaItems = mediaItems.filter({ $0.title.lowercased().contains(lowercasedSearchText) })

    tableView.reloadData()
  }

  public func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchText: searchController.searchBar.text!)
  }

}

