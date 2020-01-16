//
//  OtherViewController.swift
//  ExampleApp
//
//  Created by Michael Eisel on 1/16/20.
//  Copyright © 2020 Michael Eisel. All rights reserved.
//

import UIKit

class OtherViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .green

        let model = OtherModel(text: "I'm some other view controller")
        let label = UILabel()
        label.text = model.text
        label.frame = view.bounds
        view.addSubview(label)
    }
}
