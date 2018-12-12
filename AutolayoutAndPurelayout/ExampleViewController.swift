//
//  ExampleViewControllerType.swift
//  AutolayoutAndPurelayout
//
//  Created by 孙玉新 on 2018/12/11.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

    override open func loadView(){
        print("\(self.title ?? "") loadView~~~")
        super.loadView()
        print("\(self.title ?? "") loadView...")
    }
    
    override func viewDidLoad() {
        print("\(self.title ?? "") viewDidLoad~~~")
        super.viewDidLoad()
        print("\(self.title ?? "") viewDidLoad...")
    }

    override func viewWillAppear(_ animated: Bool) {
        print("\(self.title ?? "") viewWillAppear(\(animated))~~~")
        super.viewWillAppear(animated)

        print("\(self.title ?? "") viewWillAppear(\(animated))...")
    }

    override func viewDidAppear(_ animated: Bool) {
        print("\(self.title ?? "") viewDidAppear(\(animated))~~~")
        super.viewDidAppear(animated)
        
        print("\(self.title ?? "") viewDidAppear(\(animated))...")
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("\(self.title ?? "") viewWillDisappear(\(animated))~~~")
        super.viewWillDisappear(animated)
        
        print("\(self.title ?? "") viewWillDisappear(\(animated))...")
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("\(self.title ?? "") viewDidDisappear(\(animated))~~~")
        super.viewDidDisappear(animated)
        
        print("\(self.title ?? "") viewDidDisappear(\(animated))...")
    }

    override func viewWillLayoutSubviews() {
        print("\(self.title ?? "") viewWillLayoutSubviews~~~")
        super.viewWillLayoutSubviews()
        
        print("\(self.title ?? "") viewWillLayoutSubviews...")
    }

    override func viewDidLayoutSubviews(){
        print("\(self.title ?? "") viewDidLayoutSubviews~~~")
        super.viewDidLayoutSubviews()
        
        print("\(self.title ?? "") viewDidLayoutSubviews...")
    }


    override func updateViewConstraints() {
        print("\(self.title ?? "") updateViewConstraints~~~")
        super.updateViewConstraints()
        
        print("\(self.title ?? "") updateViewConstraints...")
    }
}
