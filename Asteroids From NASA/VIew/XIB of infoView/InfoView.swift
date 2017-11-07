//
//  infoView.swift
//  Asteroids From NASA
//
//  Created by Алексей Россошанский on 06.11.17.
//  Copyright © 2017 Alexey Rossoshasky. All rights reserved.
//

import UIKit

class InfoView: UIView {

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var minDiamLabel: UILabel!
    @IBOutlet weak var maxDiamLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("InfoView", owner: self, options: nil)
        addSubview(infoView)
        infoView.frame = self.bounds
        infoView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        infoView.layer.masksToBounds = true
        infoView.layer.cornerRadius = 10
        infoView.layer.borderWidth = 1
        infoView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

}
