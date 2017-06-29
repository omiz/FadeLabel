//
//  ViewController.swift
//  FadeExample
//
//  Created by Omar Allaham on 6/29/17.
//  Copyright © 2017 movingatom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   @IBOutlet weak var label: FadeLabel!

   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
   }

   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      Timer.scheduledTimer(timeInterval: label.fadeInDuration, target: self, selector: #selector(fade), userInfo: nil, repeats: true)
   }

   func fade() {
      label.isFadedOut ? label.fadeIn() : label.fadeOut()
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }


}

