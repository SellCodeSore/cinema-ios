//
//  DetailViewController.swift
//  Cinema
//
//  Created by Martin Bauer on 17.04.17.
//  Copyright © 2017 Martin Bauer. All rights reserved.
//

import Dispatch
import UIKit

class DetailViewController: UIViewController {

  var detailItem: MediaItem? {
    didSet {
      configureView()
    }
  }

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var runtimeLabel: UILabel!
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var certificationLabel: UILabel!
  @IBOutlet weak var diskLabel: UILabel!
  @IBOutlet weak var textView: UITextView!

  var movieDb: MovieDbClient!

  func configureView() {
    guard isViewLoaded else { return }
    if let mediaItem = detailItem {
      titleLabel.text = mediaItem.title
      if let subtitle = mediaItem.subtitle {
        subtitleLabel.isHidden = false
        subtitleLabel.text = subtitle
      } else {
        subtitleLabel.isHidden = true
      }
      runtimeLabel.text = Utils.formatDuration(mediaItem.runtime)
      yearLabel.text = "\(mediaItem.year)"
      diskLabel.text = localize(diskType: mediaItem.diskType)

      if movieDb.isConnected {
        fetchAdditionalData()
      }
    }
  }

  private func fetchAdditionalData() {
    let queue = DispatchQueue.global(qos: .userInitiated)
    let group = DispatchGroup()
    group.enter()
    queue.async {
      if let poster = self.movieDb.poster(for: self.detailItem!.id, size: .w185) {
        DispatchQueue.main.async {
          self.imageView.image = poster
          group.leave()
        }
      }
    }
    group.enter()
    queue.async {
      let overview = self.movieDb.overview(for: self.detailItem!.id) ?? "No overview available."
      DispatchQueue.main.async {
        self.textView.text = overview
        group.leave()
      }
    }
    group.enter()
    queue.async {
      let genreString = self.movieDb.genres(for: self.detailItem!.id).reduce("") { (result, next) in
        if result.isEmpty {
          return next
        } else {
          return "\(result), \(next)"
        }
      }
      DispatchQueue.main.async {
        self.genreLabel.text = genreString
        group.leave()
      }
    }
    group.enter()
    queue.async {
      let text: String
      if let certification = self.movieDb.certification(for: self.detailItem!.id) {
        text = "FSK \(certification)"
      } else {
        text = "No certification available."
      }
      DispatchQueue.main.async {
        self.certificationLabel.text = text
        group.leave()
      }
    }
    group.notify(queue: .main) {
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
  }

  private func localize(diskType: DiskType) -> String {
    switch diskType {
      case .dvd: return "DVD"
      case .bluRay: return "Blu-ray"
    }
  }

  override func viewDidLoad() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    genreLabel?.text = ""
    runtimeLabel?.text = ""
    yearLabel?.text = ""
    certificationLabel?.text = ""
    diskLabel?.text = ""
    configureView()
    super.viewDidLoad()
  }
}

