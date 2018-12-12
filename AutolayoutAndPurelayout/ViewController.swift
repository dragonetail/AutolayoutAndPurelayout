//
//  ViewController.swift
//  AutolayoutAndPurelayout
//
//  Created by 孙玉新 on 2018/12/11.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit
import PureLayout

struct ExampleSection {
    var header: String?
    var footer: String?
    var examples: [Example]
}

struct Example {
    var name: String
    var exampleViewControllerType: ExampleViewController.Type
}

class ViewController: ExampleViewController {
    static let cellIdentifier = String(describing: UITableViewCell.self)

    let exampleSections = [
        ExampleSection(header: "布局尺寸", footer: nil, examples: [
            Example(name: "尺寸拉伸", exampleViewControllerType: HuggingExampleViewController.self),
            Example(name: "尺寸压缩", exampleViewControllerType: CompressionExampleViewController.self),
            Example(name: "纯代码布局tablecell", exampleViewControllerType: CodeTableViewController.self)
        ]),
        ExampleSection(header: "Purelayout例子", footer: nil, examples: [
            Example(name: "1.Basic Auto Layout", exampleViewControllerType: PurelayoutExample1ViewController.self),
            Example(name: "2.Working with Arrays of Views", exampleViewControllerType: PurelayoutExample2ViewController.self),
            Example(name: "3.Distributing Views", exampleViewControllerType: PurelayoutExample3ViewController.self),
            Example(name: "4.Leading & Trailing Attributes", exampleViewControllerType: PurelayoutExample4ViewController.self),
            Example(name: "5.Cross-Attribute Constraints", exampleViewControllerType: PurelayoutExample5ViewController.self),
            Example(name: "6.Priorities & Inequalities", exampleViewControllerType: PurelayoutExample6ViewController.self),
            Example(name: "7.Animating Constraints", exampleViewControllerType: PurelayoutExample7ViewController.self),
            Example(name: "8.Constraint Identifiers (iOS 7.0+)", exampleViewControllerType: PurelayoutExample8ViewController.self),
            Example(name: "9.Layout Margins (iOS 8.0+)", exampleViewControllerType: PurelayoutExample9ViewController.self),
            Example(name: "10.Constraints Without Installing", exampleViewControllerType: PurelayoutExample10ViewController.self),
            Example(name: "11.Basic UIScrollView", exampleViewControllerType: PurelayoutExample11ViewController.self)
        ])
    ]

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.cellIdentifier)

        return tableView
    }()


    override func loadView() {
        super.loadView()

        setupAndComposeView()

        // bootstrap Auto Layout
        view.setNeedsUpdateConstraints()
    }

    func setupAndComposeView() {

        self.title = "Example List"

        view.addSubview(tableView)
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
        tableView.autoPinEdgesToSuperviewEdges()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return exampleSections.count
    }


    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return exampleSections[section].header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return exampleSections[section].footer
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exampleSections[section].examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellIdentifier, for: indexPath)

        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        cell.textLabel?.text = exampleSections[indexPath.section].examples[indexPath.row].name
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = exampleSections[indexPath.section].examples[indexPath.row]

        let exampleViewController = example.exampleViewControllerType.init()

        //self.show(exampleViewController, sender: nil)
        //self.present(exampleViewController, animated: false) {
        self.navigationController?.pushViewController(exampleViewController, animated: false)
    }
}
