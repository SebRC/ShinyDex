//
//  IndicatorView.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 13/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class IndicatorView: UIView
{
	let nibName = "IndicatorView"
    var contentView:UIView?
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var pokemonImageView: UIImageView!
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
    }
	
    override init(frame: CGRect)
	{
        super.init(frame: frame)
        commonInit()
    }
	
    func commonInit()
	{
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
	
    func loadViewFromNib() -> UIView?
	{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
