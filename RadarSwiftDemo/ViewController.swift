//
//  ViewController.swift
//  RadarSwiftDemo
//
//  Created by asnail on 2019/5/20.
//  Copyright © 2019 wemomo.com. All rights reserved.
//

import UIKit

func lagAWhile(time: Double) {
    DispatchQueue.main.async {
        let lastDate = Date.init()
        var i = 1;
        while (true) {
            i += 1;
            let currentDate = Date.init()
            if ((currentDate.timeIntervalSince1970 - lastDate.timeIntervalSince1970) > time) {
                break;
            }
        }
    }
}

func RGBColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return RGBAColor(r: r, g: g, b: b, a: 1.0)
}

func RGBAColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
}

class ViewController: BaseViewController {
    
    var memIndicator = RAMemoryIndicator()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Radar Demos"
        
        let left = 20, btnHeight = 50, margin = 20, btnWidth = Int(self.view.frame.size.width) - (2 * margin)
        
        var top = 100
        let move = {
            top += btnHeight + margin
        }
        
        let redColor_ = RGBColor(r: 255, g: 45, b: 85)
        let blueColor_ = RGBColor(r: 52, g: 98, b: 255)
        let greenColor_ = RGBColor(r: 80, g: 133, b: 82)
        let warnColor_ = RGBColor(r: 236, g: 112, b: 117)
        
        self.addBtn(frame: CGRect(x: left, y: top, width: btnWidth, height: btnHeight), bgColor: blueColor_, title: "Block Main Thread A While", action: #selector(ViewController.mainThreadBlock))
        move()
        
        self.addBtn(frame: CGRect(x: left, y: top, width: btnWidth, height: btnHeight), bgColor: blueColor_, title: "Check Page Time", action: #selector(ViewController.testPageTimeCost))
        move()
        
        self.addBtn(frame: CGRect(x: left, y: top, width: (btnWidth - margin) / 2, height: btnHeight), bgColor: greenColor_, title: "⤴️ Mem(40M)", action: #selector(ViewController.increaseMem))
        self.addBtn(frame: CGRect(x: left + (btnWidth - margin) / 2 + margin, y: top, width: (btnWidth - margin) / 2, height: btnHeight), bgColor: warnColor_, title: "⬇️ Mem(40M)", action: #selector(ViewController.decreaseMem))
        move()

        self.addBtn(frame: CGRect(x: left, y: top, width: btnWidth, height: btnHeight), bgColor: redColor_, title: "Push Leak Page", action: #selector(ViewController.testLeakPage))
        move()
        
        self.addBtn(frame: CGRect(x: left, y: top, width: btnWidth, height: btnHeight), bgColor: redColor_, title: "Check Mem Chunk", action: #selector(ViewController.testChunk))
        move()

        self.addBtn(frame: CGRect(x: left, y: top, width: btnWidth, height: btnHeight), bgColor: blueColor_, title: "Test Upload", action: #selector(ViewController.testUpload))
        move()
        
        let miW = 80
        memIndicator.frame = CGRect(x: Int(self.view.frame.width) - miW, y: Int(self.view.frame.height) - 50, width: miW, height: miW)
        memIndicator.setThreshhold(Double(RadarTest.getTotlePhysMemory()) * 0.4)
        memIndicator.show(true)
        
        timer = Timer.init(timeInterval: 0.03, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func addBtn(frame: CGRect, bgColor: UIColor, title: String, action: Selector) {
        let btn = UIButton.init(frame: frame)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.backgroundColor = bgColor
        btn.addTarget(self, action: action, for: .touchUpInside)
        self.view.addSubview(btn)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
    }
    
    @objc func mainThreadBlock() {
        print("main thread a while 300ms")
        lagAWhile(time: 0.3)
    }
    
    @objc func testPageTimeCost() {
        print("Push long time page")
        let ltVc = RAPageTimeCostViewController.init()
        self.navigationController?.pushViewController(ltVc, animated: true)
    }
    
    var allocatedMB = 0;
    
    var p = Array(repeating: UnsafeMutablePointer<Int8>.allocate(capacity: 0), count: 200)
    
    func AllocMem(size: Int) {
        p[allocatedMB] = UnsafeMutablePointer<Int8>.allocate(capacity: size)
        memset(p[allocatedMB], 0, size);
        allocatedMB += 1;
    }
    
    @objc func increaseMem() {
        AllocMem(size: 40 * 1048576) //40MB
    }
    
    @objc func decreaseMem() {
        if (allocatedMB > 0) {
            free(p[allocatedMB-1]);
            allocatedMB -= 1;
        }
    }
    
    @objc func testLeakPage() {
        let leakPg = RAMemLeakViewController()
        self.navigationController?.pushViewController(leakPg, animated: true)
    }
    
    @objc func testChunk() {
        AllocMem(size: 100 * 1048576)// 100MB
    }
    
    @objc func timerFired() {
        memIndicator.memory = CGFloat(RadarTest.ra_getUsedPhysMemory())
    }

    @objc func testUpload() {
        Radar.testUpload()
    }
}

// MARK: - Page Time Cost
class RAPageTimeCostViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        lagAWhile(time: 0.9)
    }
}

// MARK: - Memory Leak
class BaseLeakObj: NSObject {
    public var pointer_s = NSObject()
    override init() {
        super.init()
    }
}
class LeakObj1: BaseLeakObj {}
class LeakObj2: BaseLeakObj {}
class LeakObj3: BaseLeakObj {}
class RAMemLeakViewController: BaseViewController {
    var leakedObj = BaseLeakObj()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make retain cycle
        let leakObj1 = LeakObj1()
        leakObj1.pointer_s = self
        
        let leakObj2 = LeakObj2()
        leakObj2.pointer_s = leakObj1
        
        let leakObj3 = LeakObj3()
        leakObj3.pointer_s = leakObj2
        leakedObj = leakObj3
    }
}

