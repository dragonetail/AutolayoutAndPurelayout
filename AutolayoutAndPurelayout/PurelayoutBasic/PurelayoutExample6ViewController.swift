//
//  ViewController.swift
//  AutolayoutAndPurelayout
//
//  Created by 孙玉新 on 2018/12/11.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit
import PureLayout

class PurelayoutExample6ViewController: ExampleViewController {
    lazy var blueView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .blue
        return view
    }()

    
    override func loadView() {
        super.loadView()
        
        setupAndComposeView()
        
        // bootstrap Auto Layout
        view.setNeedsUpdateConstraints()
    }
    
    func setupAndComposeView() {
        self.title = "6.Priorities & Inequalities"
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        [blueView].forEach { (subview) in
            view.addSubview(subview)
        }
    }
    
    fileprivate var didSetupConstraints = false
    override func updateViewConstraints() {
        if (!didSetupConstraints) {
            didSetupConstraints = true
            setupConstraints()
        }
        //modifyConstraints()
        
        super.updateViewConstraints()
    }
    
    func setupConstraints() {
        // Center the blueView in its superview, and match its width to its height
        blueView.autoCenterInSuperview()
        blueView.autoMatch(.width, to: .height, of: blueView)
        
        // Make sure the blueView is always at least 20 pt from any edge
        blueView.autoPin(toTopLayoutGuideOf: self, withInset: 20.0, relation: .greaterThanOrEqual)
        blueView.autoPin(toBottomLayoutGuideOf: self, withInset: 20.0, relation: .greaterThanOrEqual)
        blueView.autoPinEdge(toSuperviewEdge: .left, withInset: 20.0, relation: .greaterThanOrEqual)
        blueView.autoPinEdge(toSuperviewEdge: .right, withInset: 20.0, relation: .greaterThanOrEqual)
        
        // Add constraints that set the size of the blueView to a ridiculously large size, but set the priority of these constraints
        // to a lower value than Required. This allows the Auto Layout solver to let these constraints be broken if one or both of
        // them conflict with higher-priority constraint(s), such as the above 4 edge constraints.
        NSLayoutConstraint.autoSetPriority(UILayoutPriority.defaultHigh) {
            self.blueView.autoSetDimensions(to: CGSize(width: 10000.0, height: 10000.0))
        }
    }
    
}
