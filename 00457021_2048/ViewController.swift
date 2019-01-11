//
//  ViewController.swift
//  00457021_2048
//
//  Created by User16 on 2019/1/11.
//  Copyright © 2019 00457021_2048. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    @IBOutlet weak var GifView: UIImageView!
    @IBAction func startGameButtonTapped(_ sender : UIButton) {
        let game = NumberTileGameViewController(dimension: 4, threshold: 2048)
        self.present(game, animated: true, completion: nil)
    }
}

