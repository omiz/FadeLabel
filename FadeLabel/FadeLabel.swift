//
//  FadeLabel.swift
//  FadeLabel
//
//  Created by Omar Allaham on 6/29/17.
//  Copyright © 2017 movingatom. All rights reserved.
//

import UIKit

class FadeLabel: UILabel {

   /**
    *  Fade in text animation duration.
    */

   @IBInspectable var fadeInDuration: CFTimeInterval = 1

   /**
    *  Fade out duration.
    */
   @IBInspectable var fadeoutDuration: CFTimeInterval = 1


   /**
    *  Auto start the animation.
    */
   @IBInspectable var isAutoStart: Bool = false

   /**
    *  Check if the animation is finished
    */
   var isFading: Bool {
      return !displaylink.isPaused
   }

   /**
    *  Check if visible
    */
   var isVisible: Bool {
      return !isFadedOut
   }

   fileprivate var completion: (() -> Swift.Void)?

   fileprivate var characterAnimationDurations: [Double] = []
   fileprivate var characterAnimationDelays: [Double] = []
   fileprivate var displaylink: CADisplayLink!

   fileprivate var beginTime: CFTimeInterval = 0
   fileprivate var endTime: CFTimeInterval = 0

   private(set) var isFadedOut: Bool = true

   // MARK: - init

   init() {
      super.init(frame: CGRect.zero)

      commonInit()
   }

   override init(frame: CGRect) {
      super.init(frame: frame)

      commonInit()
   }

   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)

      commonInit()

      text = text ?? ""
   }

   override var text: String? {
      didSet {
         attributedText = attribute(NSAttributedString(string: text ?? ""))
      }
   }

   override var attributedText: NSAttributedString? {
      didSet {
         self.attributedString = attribute(attributedText)
         let count = attributedText?.length ?? 0
         (0 ..< count).forEach { _ in
            characterAnimationDelays.append(Double(arc4random_uniform(UInt32(fadeInDuration / 2 * 100)) / 100))
            let remain = UInt32(fadeInDuration - (characterAnimationDelays.last ?? 0))
            characterAnimationDurations.append(Double(arc4random_uniform(remain * 100)) / 100)
         }
      }
   }

   fileprivate var attributedString: NSMutableAttributedString?

   func commonInit() {

      displaylink = CADisplayLink(target: self, selector: #selector(updateAttributedString))
      displaylink?.isPaused = true

      displaylink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
   }

   override func didMoveToWindow() {
      super.didMoveToWindow()

      if (nil != self.window && self.isAutoStart) {
         fadeIn()
      }
   }

   /**
    *  Start the animation
    */
   func fadeIn(_ completion: @escaping (() -> Swift.Void) = {}) {

      guard !isFading && isFadedOut else { return }

      self.completion = completion

      isFadedOut = false

      startAnimation(fadeInDuration)

   }

   func fadeOut(_ completion: @escaping (() -> Swift.Void) = {} ) {

      guard !isFading && !isFadedOut else { return }

      self.completion = completion

      isFadedOut = true

      startAnimation(fadeInDuration)
   }

   func startAnimation(_ duration: CFTimeInterval) {

      beginTime = CACurrentMediaTime()

      endTime = beginTime + fadeInDuration

      displaylink.isPaused = false

   }

   func updateAttributedString() {

      let now = CACurrentMediaTime()

      let count = attributedString?.length ?? 0

      let set = NSCharacterSet.whitespacesAndNewlines

      let chars = attributedString?.string.characters.map { $0.description } ?? []

      for i in 0 ..< count {

         if chars[i].trimmingCharacters(in: set).isEmpty { continue }

         attributedString?.enumerateAttribute(NSForegroundColorAttributeName, in: NSRange(location: i, length: 1), options:NSAttributedString.EnumerationOptions(rawValue: 0)){ (attribute, range, other) in

            guard let attribute = attribute else { return }

            guard let color = attribute as? UIColor else { return }

            let currentAlpha = color.cgColor.alpha

            let shouldUpdateAlpha = isFadedOut && currentAlpha > 0 || (isFadedOut && currentAlpha < 1) || (now - beginTime) >= characterAnimationDelays[i]


            if !shouldUpdateAlpha { return }

            var percentage: CGFloat = CGFloat((now - self.beginTime - characterAnimationDelays[i]) / ( characterAnimationDurations[i]))

            if (isFadedOut) {
               percentage = 1 - percentage
            }

            let newColor = color.withAlphaComponent(percentage)
            attributedString?.addAttribute(NSForegroundColorAttributeName, value: newColor, range: range)
         }
      }

      super.attributedText = attributedString

      if now > endTime {
         displaylink.isPaused = true
         completion?()
      }
   }

   func attribute(_ text: NSAttributedString?) -> NSMutableAttributedString {

      guard let text = text else { return NSMutableAttributedString() }

      let attributedText = text.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
      let color = textColor.withAlphaComponent(0)

      attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange.init(location: 0, length: attributedText.length))

      return attributedText
   }

}

extension UIColor {
   var hex: String {
      let comps = cgColor.components!
      let r = Int(comps.count > 0 ? comps[0] * 255 : 0)
      let g = Int(comps.count > 1 ? comps[1] * 255 : 0)
      let b = Int(comps.count > 2 ? comps[2] * 255 : 0)
      let a = Int(comps.count > 3 ? comps[3] * 255 : 0)
      var hexString: String = ""
      hexString = "#"
      hexString += String(format: "%02X%02X%02X", r, g, b)
      
      hexString += String(format: "%02X", a)
      
      return hexString
   }
}
