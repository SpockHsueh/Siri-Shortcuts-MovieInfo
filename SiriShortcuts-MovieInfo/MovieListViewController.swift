//
//  MovieListViewController.swift
//  SiriShortcuts-MovieInfo
//
//  Created by Spock on 2019/4/13.
//  Copyright © 2019 Spock. All rights reserved.
//

import UIKit
import Intents
import MovieKit

class MovieListViewControlller: UICollectionViewController {
    
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var endpoint: MovieRepository.Endpoint
    var movieRepository: MovieRepository
    var movies = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init(endpoint: MovieRepository.Endpoint, movieRepository: MovieRepository = MovieRepository.shared) {
        self.endpoint = endpoint
        self.movieRepository = movieRepository
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        refresh()
        donateIntent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    public func handleActivity(_ activity: NSUserActivity) {
        let intent = activity.interaction?.intent as! INSendMessageIntent
        print(intent.content)
    }
    
    private func setupCollectionView() {
        title = endpoint.description
        
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    
        collectionView.register(MovieCollectionViewCell.nib, forCellWithReuseIdentifier: "Cell")
                
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let screenWidth = UIScreen.main.bounds.width
        
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 2
        layout.sectionInset.top = 1
        layout.sectionInset.bottom = 1
        
        let itemWidth: CGFloat = (screenWidth / 3.0).rounded(.down)
        let itemSize = CGSize(width: itemWidth - 1.0 , height: (itemWidth * 3) / 2)
        layout.itemSize = itemSize
    }
    
    
    @objc private func refresh() {
        fetchMovies()
    }
    
    private func donateIntent() {
        INPreferences.requestSiriAuthorization { [weak self](authorization) in
            
            guard let strongSelf = self else {
                return
            }
            guard authorization == INSiriAuthorizationStatus.authorized else {
                return
            }
            
            print("Authorized")
            
            let intent = MoviesIntent()
            intent.endpoint = strongSelf.endpoint.description
            intent.suggestedInvocationPhrase = "\(strongSelf.endpoint.description) movies"
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.donate(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    private func fetchMovies() {
        if movies.isEmpty {
            activityIndicator.startAnimating()
        }
        
        movieRepository.fetchMovies(from: endpoint, params: ["page": "page"], successHandler: {[weak self] (response) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.collectionView.refreshControl?.endRefreshing()
                self!.movies = response.results
            }
        }) {[weak self] (error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.collectionView.refreshControl?.endRefreshing()
                self?.collectionView.reloadData()
                print(error.localizedDescription)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MovieCollectionViewCell
        let movie = movies[indexPath.row]
        cell.movie = movie
        return cell
    }
    
}
