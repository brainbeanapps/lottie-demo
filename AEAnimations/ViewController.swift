//
//  ViewController.swift
//  AEAnimations
//
//  Created by Igor Dorofix on 10/3/17.
//  Copyright © 2017 BrainBeanApps LLC. All rights reserved.
//

import UIKit
import Lottie
import keyframes

enum SegmentButton: Int {
    case firstButton
    case secondButton
    
    func from() -> CGFloat {
        switch self {
        case .firstButton:
            return 0.5
        case .secondButton:
            return 0.05
        }
    }
    
    func to() -> CGFloat {
        switch self {
        case .firstButton:
            return 1
        case .secondButton:
            return 0.5
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    lazy var tabAnimation: LOTAnimationView = {
        let animation = LOTAnimationView(name: "data")
        animation.animationSpeed = 3.5
        view.addSubview(animation)
        view.sendSubview(toBack: animation)
        return animation
    }()
    
    lazy var starLabel: UILabel = {
        let label = UILabel()
        label.text = "666"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        return label
    }()
    
    lazy var starAnimation: LOTAnimationView = {
        let animation = LOTAnimationView(name: "star")
        animation.isHidden = true
        view.addSubview(animation)
        return animation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabAnimation.frame = CGRect(x: 0, y: firstButton.frame.minY, width: view.bounds.width, height: firstButton.bounds.height + 4)
        
        starAnimation.center = view.center
        starAnimation.frame = starAnimation.frame.insetBy(dx: -50, dy: -50)
    }
    
    @IBAction func selectSegmentButton(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        
        sender.isSelected = true
        let segmentButton = SegmentButton(rawValue: sender.tag)!
        let oponentButton = sender.tag == SegmentButton.firstButton.rawValue ? secondButton : firstButton
        tabAnimation.play(fromProgress: segmentButton.from(), toProgress: segmentButton.to(), withCompletion: { (finished) in
            print("TabAnimation completed")
            oponentButton?.isSelected = false
        })
    }
    
    @IBAction func showKeyFramesStar(_ sender: UIButton) {
        
        let sampleVector : KFVector!
        do {
            sampleVector = try self.loadSampleVectorFromDisk()
        } catch {
            print("Vector file could not be loaded, aborting")
            return
        }
        
        let sampleVectorLayer : KFVectorLayer = KFVectorLayer()
        
        sampleVectorLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        sampleVectorLayer.setFaceModel(sampleVector)
        
        self.view.layer.addSublayer(sampleVectorLayer)
        sampleVectorLayer.startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSampleVectorFromDisk() throws -> KFVector {
        let filePath : String = Bundle(for: type(of: self)).path(forResource: "keyframes_star_text", ofType: "json")!
        let data : Data = try String(contentsOfFile: filePath).data(using: .utf8)!
        let sampleVectorDictionary : Dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
        
        return KFVectorFromDictionary(sampleVectorDictionary)
    }
    
    @IBAction func showTextStar(_ sender: UIButton) {
        let labelRect = starAnimation.convert(CGRect(x: -136, y: -150, width: 300, height: 300), toLayerNamed: nil)
        starLabel.frame = labelRect
        starAnimation.addSubview(starLabel, toLayerNamed: "ic_fav_fill", applyTransform: true)
        
        starAnimation.isHidden = false
        starAnimation.play { [weak self] finished in
            self?.starAnimation.isHidden = true
            self?.starLabel.removeFromSuperview()
            self?.starLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        }
    }
    
    @IBAction func showStar(_ sender: UIButton) {
        starLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        let labelImage = UIImageView(image: UIImage.imageWithLabel(label: starLabel))
        let labelRect = starAnimation.convert(CGRect(x: -136, y: -150, width: 300, height: 300), toLayerNamed: nil)
        labelImage.frame = labelRect
        starAnimation.addSubview(labelImage, toLayerNamed: "ic_fav_fill", applyTransform: true)
        
        starAnimation.isHidden = false
        starAnimation.play { [weak self] finished in
            self?.starAnimation.isHidden = true
            labelImage.removeFromSuperview()
        }
    }
}

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in:context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
