//
//  MovieCollectionViewCell.swift
//  MovieKit
//
//  Created by Spock on 2019/4/14.
//  Copyright © 2019 Spock. All rights reserved.
//

import UIKit
import Kingfisher

public class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    public static var nib: UINib {
        return UINib(nibName: "MovieCollectionViewCell", bundle: Bundle(for: MovieCollectionViewCell.self))
    }
    
    public var movie: Movie! {
        didSet {
            self.titleLabel.text = movie?.title
            self.imageView.kf.setImage(with: movie?.posterURL, placeholder: nil, options: nil, progressBlock: nil) { (_, error, _, _) in
                self.titleLabel.isHidden = error == nil
            }
            
            let voteCount = movie?.voteCount ?? 0
            if voteCount > 0 {
                ratingLabel.text = movie.voteAveragePercentText
            } else {
                ratingLabel.isHidden = true
            }
            
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        imageView.kf.indicatorType = .activity
        ratingLabel.backgroundColor = UIColor(white: 0.25, alpha: 0.5)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.isHidden = false
        ratingLabel.isHidden = false
    }
    
}
