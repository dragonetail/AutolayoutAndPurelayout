//
//  ViewController.swift
//  AutolayoutAndPurelayout
//
//  Created by 孙玉新 on 2018/12/11.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit
import PureLayout

class PurelayoutExample4ViewController: ExampleViewController {
    lazy var blueLabel: UILabel = {
        let label = UILabel.newAutoLayout()
        label.backgroundColor = .blue
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.textColor = .white
        label.text = NSLocalizedString("Lorem ipsum", comment: "")
        return label
    }()
    lazy var redLabel: UILabel = {
        let label = UILabel.newAutoLayout()
        label.backgroundColor = .red
        label.numberOfLines = 0
        label.textColor = .white
        label.text = NSLocalizedString("Lorem ipsum", comment: "")
        return label
    }()
    lazy var greenView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .green
        return view
    }()


    override func loadView() {
        super.loadView()

        setupAndComposeView()

        // bootstrap Auto Layout
        view.setNeedsUpdateConstraints()
    }

    func setupAndComposeView() {
        self.title = "4.Leading & Trailing Attributes"
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)

        [blueLabel, redLabel, greenView].forEach { (subview) in
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
        /**
         NOTE: To observe the effect of leading & trailing attributes, you need to change the OS language setting from a left-to-right language,
         such as English, to a right-to-left language, such as Arabic.
         
         This demo project includes localized strings for Arabic, so you will see the Lorem Ipsum text in Arabic if the system is set to that language.
         
         See this method of easily forcing the simulator's language from Xcode: http://stackoverflow.com/questions/8596168/xcode-run-project-with-specified-localization
         */

        let smallPadding: CGFloat = 20.0
        let largePadding: CGFloat = 50.0

        // Prevent the blueLabel from compressing smaller than required to fit its single line of text
        blueLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

        // Position the single-line blueLabel at the top of the screen spanning the width, with some small insets
        blueLabel.autoPin(toTopLayoutGuideOf: self, withInset: smallPadding)
        blueLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: smallPadding)
        blueLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: smallPadding)

        // Make the redLabel 60% of the width of the blueLabel
        redLabel.autoMatch(.width, to: .width, of: blueLabel, withMultiplier: 0.6)

        // The redLabel is positioned below the blueLabel, with its leading edge to its superview, and trailing edge to the greenView
        redLabel.autoPinEdge(.top, to: .bottom, of: blueLabel, withOffset: smallPadding)
        redLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: smallPadding)
        redLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: largePadding)

        // The greenView is positioned below the blueLabel, with its leading edge to the redLabel, and trailing edge to its superview
        greenView.autoPinEdge(.leading, to: .trailing, of: redLabel, withOffset: largePadding)
        greenView.autoPinEdge(.top, to: .bottom, of: blueLabel, withOffset: smallPadding)
        greenView.autoPinEdge(toSuperviewEdge: .trailing, withInset: smallPadding)

        // Match the greenView's height to its width (keeping a consistent aspect ratio)
        greenView.autoMatch(.width, to: .height, of: greenView)
    }

}
