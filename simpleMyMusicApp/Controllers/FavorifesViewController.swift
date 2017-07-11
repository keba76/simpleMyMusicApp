//
//  FavorifesViewController.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit
import SDWebImage

class EmptyCell: UITableViewCell {}

class FavorifesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModelForFavorites = [AudioViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.navigationItem.title = "Favorites"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.allowsSelection = false
        AppUtility.lockOrientation(.portrait)
        selectFavorites()
    }
    
    func selectFavorites() {
        self.viewModelForFavorites = []
        let countAudioViewModel = AudioViewModelController.share.viewModelsCount
        var delta = 0
        while delta != countAudioViewModel {
            let model = AudioViewModelController.share.viewModel(at: delta)
            if model!.favorites {
                self.viewModelForFavorites.append(model!)
            }
            delta += 1
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModelForFavorites.count > 0 ? self.viewModelForFavorites.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.viewModelForFavorites.count > 0 {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! FavoritesCell
        
        cell.title.text = self.viewModelForFavorites[indexPath.row].title
        cell.pic.sd_setImage(with: self.viewModelForFavorites[indexPath.row].images)
        return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
            return cell
        }
    }
}
