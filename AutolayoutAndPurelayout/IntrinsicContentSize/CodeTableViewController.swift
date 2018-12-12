//
//  ViewController.swift
//  AutolayoutAndPurelayout
//
//  Created by 孙玉新 on 2018/12/11.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit
import PureLayout

struct CellModel {
    var name: String
    var company: String
    var content: String
    var cacheHeight: CGFloat

    static func load() -> [CellModel] {
        guard let resourcePath = Bundle.main.path(forResource: "SampleData", ofType: "plist"),
            let array = NSArray.init(contentsOfFile: resourcePath) as? [NSDictionary] else {
                return [CellModel]()
        }

        var models = [CellModel]()
        array.forEach({ (dict) in
            let name = dict["sampleName"] as! String
            let company = dict["sampleCompany"] as! String
            let content = dict["simpleContent"] as! String

            let model = CellModel(name: name, company: company, content: content, cacheHeight: 0)
            models.append(model)
        })
        return models
    }
}

class CodeLayoutCell: UITableViewCell {
    lazy var cellImageView: UIImageView = {
        let cellImageView = UIImageView()
        cellImageView.image = UIImage(named: "kakaxi")
        return cellImageView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()

        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black;
        label.font = UIFont.systemFont(ofSize: 14);
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left;

        return label
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel()

        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black;
        label.font = UIFont.systemFont(ofSize: 12);
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left;

        return label
    }()
    lazy var companyLabel: UILabel = {
        let label = UILabel()

        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black;
        label.font = UIFont.systemFont(ofSize: 10);
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left;

        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupAndComposeView()
        
        // bootstrap Auto Layout
        self.setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Should overritted by subclass, setup view and compose subviews
    func setupAndComposeView() {
        [cellImageView, nameLabel, contentLabel, companyLabel].forEach { (subview) in
            self.contentView.addSubview(subview)
        }
    }

    fileprivate var didSetupConstraints = false
    override func updateConstraints() {
        if (!didSetupConstraints) {
            didSetupConstraints = true
            setupConstraints()
        }
        //modifyConstraints()
        
        super.updateConstraints()
    }
    
    // invoked only once
    func setupConstraints() {
        
        //图片距左边距离为10，上下居中
        cellImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        //cellImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        cellImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 10, relation: .lessThanOrEqual)
        cellImageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10, relation: .greaterThanOrEqual)

        //标题Label,一行显示
        nameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 10, relation: .lessThanOrEqual)
        nameLabel.autoPinEdge(.left, to: .right, of: cellImageView, withOffset: 6)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 10)

        //内容label,多行显示
        contentLabel.numberOfLines = 0;
        contentLabel.autoPinEdge(.left, to: .left, of: nameLabel)
        contentLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 4)

        //标题Label,一行显示
        companyLabel.autoPinEdge(.left, to: .left, of: nameLabel)
        companyLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 10, relation: .lessThanOrEqual)
        companyLabel.autoPinEdge(.top, to: .bottom, of: contentLabel, withOffset: 6)
        companyLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10, relation: .greaterThanOrEqual)


        //设置比缺省值小，则容易被拉伸
        //intrinsicView2.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .vertical)
        //设置比缺省值小，则容易被压缩
        //label2.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
        //.required == 1000
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        contentLabel.setContentHuggingPriority(.required, for: .vertical)
        companyLabel.setContentHuggingPriority(.required, for: .vertical)

//        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
//        contentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
//        companyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        //UILayoutPriority(rawValue: 250.0) UILayoutPriority(rawValue: 750.0) UILayoutPriority(rawValue: 1000.0) UILayoutPriority(rawValue: 50.0)
        //print(UILayoutPriority.defaultLow, UILayoutPriority.defaultHigh, UILayoutPriority.required, UILayoutPriority.fittingSizeLevel)
        cellImageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .vertical)
        cellImageView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        cellImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        cellImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
    }

    override func layoutSubviews() {
        contentLabel.preferredMaxLayoutWidth = self.contentView.frame.width - 128 - 10 - 6;
        super.layoutSubviews()
    }

    func setLabelText(model: CellModel) {
        nameLabel.text = model.name
        contentLabel.text = model.content
        companyLabel.text = model.company
    }
}

class CodeTableViewController: ExampleViewController {
    static let cellIdentifier = String(describing: CodeLayoutCell.self)

    let data: [CellModel] = CellModel.load()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(CodeLayoutCell.self, forCellReuseIdentifier: CodeTableViewController.cellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

        return tableView
    }()

    override func loadView() {
        super.loadView()

        setupAndComposeView()

        // bootstrap Auto Layout
        view.setNeedsUpdateConstraints()
    }

    func setupAndComposeView() {
        self.title = "纯代码布局tablecell"

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

extension CodeTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CodeTableViewController.cellIdentifier, for: indexPath) as! CodeLayoutCell

        let model = data[indexPath.row]
        cell.setLabelText(model: model)

        return cell
    }

    static var sampleCell: CodeLayoutCell?
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var model = data[indexPath.row]
        if(model.cacheHeight != 0) {
            return model.cacheHeight
        }


        DispatchQueue.once {
            let cell = tableView.dequeueReusableCell(withIdentifier: CodeTableViewController.cellIdentifier) as! CodeLayoutCell //如果追加了indexpath参数，会递归调用heightForRowAt方法
            CodeTableViewController.sampleCell = cell
        }
        guard let cell = CodeTableViewController.sampleCell else {
            return 0
        }


        cell.layoutIfNeeded()
        cell.setLabelText(model: model)
        let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        model.cacheHeight = size.height + 1 ////cell和cell.contentView的高低相差1
        print("Row: \(indexPath.row) TextLength: \(model.content.count) Height: \(model.cacheHeight)")
        return model.cacheHeight
    }
}
extension CodeTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}


public extension DispatchQueue {
    private static var _onceTracker = [String]()

    public class func once(file: String = #file, function: String = #function, line: Int = #line, block: () -> Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }


        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}
