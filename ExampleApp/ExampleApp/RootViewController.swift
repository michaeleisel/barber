//
//  ViewController.swift
//  ExampleApp
//
//  Created by Michael Eisel on 1/16/20.
//  Copyright © 2020 Michael Eisel. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow

        let model = RootModel(text: "I'm the root view controller")
        let label = UILabel()
        label.text = model.text
        label.frame = view.bounds
        view.addSubview(label)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.present(OtherViewController(), animated: true, completion: nil)
        }
    }
}

