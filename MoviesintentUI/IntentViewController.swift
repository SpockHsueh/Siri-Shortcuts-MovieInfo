//
//  IntentViewController.swift
//  MoviesIntentUI
//
//  Created by Spock on 2019/4/14.
//  Copyright © 2019 Spock. All rights reserved.
//

import IntentsUI
import MovieKit

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let repository = MovieRepository.shared

    var movies = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCollectionViewCell.nib, forCellWithReuseIdentifier: "Cell")
    }
    
    
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        guard
            let intent = interaction.intent as? MoviesIntent,
            let endpointString = intent.endpoint,
            let endpoint = MovieRepository.Endpoint(description: endpointString)
        else {
            completion(true, parameters, self.desiredSize)
            return
        }
        
        repository.fetchMovies(from: endpoint, successHandler: { (response) in
            DispatchQueue.main.async {
                let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                let screenWidth = self.view.bounds.width
                layout.minimumInteritemSpacing = 1
                layout.minimumLineSpacing = 2
                layout.sectionInset.top = 1
                layout.sectionInset.bottom = 1
                
                let itemWidth: CGFloat = (screenWidth / 3.0).rounded(.down)
                let itemSize = CGSize(width: itemWidth - 1.0, height: (itemWidth * 3) / 2)
                layout.itemSize = itemSize
                self.movies = response.results
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        let size = self.extensionContext!.hostedViewMaximumAllowedSize
        return size
    }
    
}

extension IntentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MovieCollectionViewCell
        
        cell.movie = movies[indexPath.item]
        return cell
    }
}
