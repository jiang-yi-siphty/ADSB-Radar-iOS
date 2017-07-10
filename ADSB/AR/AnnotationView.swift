/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

protocol AnnotationViewDelegate {
  func didTouch(annotationView: AnnotationView)
}


class AnnotationView: ARAnnotationView {
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var speedLabel: UILabel?
    var altitudeLabel: UILabel?
    
    var delegate: AnnotationViewDelegate?

    override func didMoveToSuperview() {
    super.didMoveToSuperview()

    loadUI()
    }
  
  func loadUI() {
    titleLabel?.removeFromSuperview()
    distanceLabel?.removeFromSuperview()

    let label = UILabel(frame: CGRect(x: 2, y: 0, width: 50, height: 13))
    label.font = UIFont.systemFont(ofSize: 10)
    label.numberOfLines = 0
    label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    label.textColor = UIColor.white
    self.addSubview(label)
    self.titleLabel = label
    
    distanceLabel = UILabel(frame: CGRect(x: 2, y: 13, width: 50, height: 10))
    distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    distanceLabel?.textColor = UIColor.green
    distanceLabel?.font = UIFont.systemFont(ofSize: 8)
    self.addSubview(distanceLabel!)
    
    speedLabel = UILabel(frame: CGRect(x: 2, y: 23, width: 50, height: 10))
    speedLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    speedLabel?.textColor = UIColor.green
    speedLabel?.font = UIFont.systemFont(ofSize: 8)
    self.addSubview(speedLabel!)

    altitudeLabel = UILabel(frame: CGRect(x: 2, y: 33, width: 50, height: 10))
    altitudeLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    altitudeLabel?.textColor = UIColor.green
    altitudeLabel?.font = UIFont.systemFont(ofSize: 8)
    self.addSubview(altitudeLabel!)

    
    if let annotation = annotation  {
        titleLabel?.text = annotation.aircraft?.callsign
        let distance = annotation.aircraft?.ViewerDistance ?? 0
        distanceLabel?.text = String(format: "%.1f km", Float(distance) )
        
        let speed = annotation.aircraft?.groundSpeed ?? 0
        speedLabel?.text = String(format: "%.1f km/h", Float(speed) )
        
        let altitude = annotation.aircraft?.presAltitude ?? 0
        altitudeLabel?.text = String(format: "%.0f feet", altitude)
      
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
//    titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
//    distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.didTouch(annotationView: self)
  }
}
