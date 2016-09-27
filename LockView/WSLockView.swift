//
//  WSLockView.swift
//  LockView
//
//  Created by 李越 on 15/12/25.
//  Copyright © 2015年 liyue. All rights reserved.
//

import UIKit

@objc public protocol WSLockViewDelegate {
    @objc optional func lockView(_ lockView: WSLockView, didFinishPath path: String)
    @objc optional func lockView(_ lockView: WSLockView, didFinishImage image: UIImage!)
}

public struct WSCircle {
    public var origin: CGPoint
    public var radius: CGFloat
    
    init() {
        self.origin = CGPoint.zero
        self.radius = 0
    }
    
    init(origin: CGPoint, radius: CGFloat) {
        self.origin = origin
        self.radius = radius
    }
}

let kScreenWidth = UIScreen.main.bounds.size.width

open class WSLockView: UIView {
    
    open weak var delegate: WSLockViewDelegate?
    
    //按钮大小
    open var btnSize: CGFloat = 74.0
    
    //按钮数量，仅限可以开平方且大于等于4的数字，并且不能大于99
    open var btnCount: Int = 9 {
        didSet {
            if btnCount > 99 {
                btnCount = oldValue
                return
            }
            
            let x = Int(sqrt(Float(btnCount)))
            
            if x*x != btnCount {
                btnCount = oldValue
            }
        }
    }
    
    fileprivate lazy var columnCount: Int = {
        return Int(sqrt(Double(self.btnCount)))
    }()
    
    //连线颜色
    open lazy var lineColor: UIColor = UIColor.blue
    
    //连线宽度
    open var lineWidth: CGFloat = 8.0
    
    //使用圆形区域按钮
    open var useCircleArea: Bool = true
    
    //当前运动的点
    fileprivate var currentPoint: CGPoint?
    
    fileprivate lazy var selectedButtons = [UIButton]()
    
    // MARK: - init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addButtons()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addButtons()
    }
    
    fileprivate func addButtons() {
        //边距
        let marginH: CGFloat = (self.frame.size.width - CGFloat(columnCount) * btnSize) / CGFloat(columnCount + 1)
        let marginV: CGFloat = (self.frame.size.height - CGFloat(columnCount) * btnSize) / CGFloat(columnCount + 1)
        
        for i in 0..<btnCount {
            let btn = UIButton(type: .custom)
            btn.tag = i
            
            btn.setBackgroundImage(UIImage(named: "gesture_node_normal"), for: UIControlState())
            btn.setBackgroundImage(UIImage(named: "gesture_node_highlighted"), for: .selected)
            btn.isUserInteractionEnabled = false
            
            let row = i / columnCount
            let col = i % columnCount
            
            //x
            let btnX = marginH + CGFloat(col) * (btnSize + marginH)
            
            //y
            let btnY = marginV + CGFloat(row) * (btnSize + marginV)
            
            btn.frame = CGRect(x: btnX, y: btnY, width: btnSize, height: btnSize)
            
            self.addSubview(btn)
        }
    }
    
    // MARK: - private functions
    
    fileprivate func pointWith(_ touches: Set<UITouch>) -> CGPoint? {
        let touch = (touches as NSSet).anyObject() as? UITouch
        
        let point = touch?.location(in: self)
        return point
    }
    
    fileprivate func buttonWith(_ point: CGPoint) -> UIButton? {
        for button in self.subviews {
            if useCircleArea {
                if circleContainsPoint(WSCircle(origin: button.center, radius: button.frame.size.width / 2), point: point) {
                    return button as? UIButton
                }
            } else {
                if button.frame.contains(point) {
                    return button as? UIButton
                }
            }
        }
        
        return nil
    }
    
    fileprivate func circleContainsPoint(_ circle: WSCircle, point: CGPoint) -> Bool {
        let x = circle.origin.x - point.x
        let y = circle.origin.y - point.y
        
        let distance = sqrt( pow(x, 2) + pow(y, 2) )
        
        return distance < circle.radius
    }
    
    // MARK: - 绘图

    override open func draw(_ rect: CGRect) {
        if self.selectedButtons.isEmpty {
            return
        }
        
        let path: UIBezierPath = UIBezierPath()
        path.lineWidth = lineWidth
        path.lineJoinStyle = .round
        
        lineColor.set()
        
        for (index, btn) in self.selectedButtons.enumerated() {
            if index == 0 {
                path.move(to: btn.center)
            } else {
                path.addLine(to: btn.center)
            }
        }
        
        if self.currentPoint != nil {
            path.addLine(to: self.currentPoint!)
        }
        
        path.stroke()
    }
    
    // MARK: - 触摸方法
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = self.pointWith(touches) else {
            return
        }
        
        guard let btn = self.buttonWith(point) else {
            return
        }
        
        if btn.isSelected == false {
            btn.isSelected = true
            self.selectedButtons.append(btn)
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = self.pointWith(touches) else {
            return
        }
        
        if let btn = self.buttonWith(point) {
            if btn.isSelected == false {
                btn.isSelected = true
                self.selectedButtons.append(btn)
            }
        }
        
        self.currentPoint = point
        
        self.setNeedsDisplay()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var path = String()
        self.selectedButtons.forEach { (btn: UIButton) -> () in
            path = path.appendingFormat("%02d", btn.tag)
        }
        
        self.delegate?.lockView?(self, didFinishPath: path)
        
        if self.currentPoint != nil {
            self.currentPoint = nil
            self.setNeedsDisplay()
        }
        
        UIGraphicsBeginImageContext(self.bounds.size)
        if let ctx = UIGraphicsGetCurrentContext() {
            self.layer.render(in: ctx)
        }
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.delegate?.lockView?(self, didFinishImage: thumbnail)
        
        //清空按钮
        self.selectedButtons.forEach { (btn: UIButton) -> () in
            btn.isSelected = false
        }
        
        self.selectedButtons.removeAll()
        
        self.setNeedsDisplay()
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(((touches == nil) ? touches : Set<UITouch>()), with: event)
    }

}
