//
//  ViewController.swift
//  AutolayoutAndPurelayout
//
//  Created by 孙玉新 on 2018/12/11.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit
import PureLayout

class CompressionExampleViewController: ExampleViewController {
    lazy var label1: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.purple
        label.numberOfLines = 1
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "压缩阻力优先级测试"

        return label
    }()
    lazy var label2: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.purple
        label.numberOfLines = 1
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "压缩阻力优先级测试"

        return label
    }()

    override func loadView() {
        super.loadView()

        setupAndComposeView()

        // bootstrap Auto Layout
        view.setNeedsUpdateConstraints()
    }

    func setupAndComposeView() {
        self.title = "抗压能力优先级测试"

        [label1, label2].forEach { (subview) in
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
        label1.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        label2.autoPinEdge(toSuperviewEdge: .right, withInset: 20)

        label2.autoPinEdge(.left, to: .right, of: label1, withOffset: 100)

        label1.autoPinEdge(toSuperviewSafeArea: .top, withInset: 80)
        label2.autoPinEdge(.top, to: .top, of: label1)

        //设置比缺省值小，则容易被压缩
        label2.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
    }

}
