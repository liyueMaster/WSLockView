//
//  WSLockView.swift
//  LockView
//
//  Created by 李越 on 15/12/25.
//  Copyright © 2015年 北京中知智慧科技有限公司. All rights reserved.
//

import UIKit

@objc public protocol WSLockViewDelegate {
    func lockView(lockView: WSLockView, didFinishPath path: String)
}




public struct WSCircle {
    public var origin: CGPoint
    public var radius: CGFloat
    
    init() {
        self.origin = CGPointZero
        self.radius = 0
    }
    
    init(origin: CGPoint, radius: CGFloat) {
        self.origin = origin
        self.radius = radius
    }
}

let kScreenWidth = UIScreen.mainScreen().bounds.size.width

public class WSLockView: UIView {
    
    public weak var delegate: WSLockViewDelegate?
    
    //按钮大小
    public var btnSize: CGFloat = 74.0
    
    //按钮数量，仅限可以开平方且大于等于4的数字
    public var btnCount: Int = 9
    
    private lazy var columnCount: Int = {
        return Int(sqrt(Double(self.btnCount)))
    }()
    
    //连线颜色
    public lazy var lineColor: UIColor = UIColor.blueColor()
    
    //连线宽度
    public var lineWidth: CGFloat = 8.0
    
    //使用圆形区域按钮
    public var useCircleArea: Bool = true
    
    //当前运动的点
    private var currentPoint: CGPoint?
    
    private lazy var selectedButtons = [UIButton]()
    
    // MARK: - init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addButtons()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addButtons()
    }
    
    private func addButtons() {
        //边距
        let marginH: CGFloat = (self.frame.size.width - CGFloat(columnCount) * btnSize) / CGFloat(columnCount + 1)
        let marginV: CGFloat = (self.frame.size.height - CGFloat(columnCount) * btnSize) / CGFloat(columnCount + 1)
        
        for i in 0..<btnCount {
            let btn = UIButton(type: .Custom)
            btn.tag = i
            
            btn.setBackgroundImage(UIImage(named: "gesture_node_normal"), forState: .Normal)
            btn.setBackgroundImage(UIImage(named: "gesture_node_highlighted"), forState: .Selected)
            btn.userInteractionEnabled = false
            
            let row = i / columnCount
            let col = i % columnCount
            
            //x
            let btnX = marginH + CGFloat(col) * (btnSize + marginH)
            
            //y
            let btnY = marginV + CGFloat(row) * (btnSize + marginV)
            
            btn.frame = CGRectMake(btnX, btnY, btnSize, btnSize)
            
            self.addSubview(btn)
        }
    }
    
    // MARK: - private functions
    
    private func pointWith(touches: Set<UITouch>) -> CGPoint? {
        let touch = (touches as NSSet).anyObject() as? UITouch
        
        let point = touch?.locationInView(self)
        return point
    }
    
    private func buttonWith(point: CGPoint) -> UIButton? {
        for button in self.subviews {
            if useCircleArea {
                if circleContainsPoint(WSCircle(origin: button.center, radius: button.frame.size.width / 2), point: point) {
                    return button as? UIButton
                }
            } else {
                if CGRectContainsPoint(button.frame, point) {
                    return button as? UIButton
                }
            }
        }
        
        return nil
    }
    
    private func circleContainsPoint(circle: WSCircle, point: CGPoint) -> Bool {
        let x = circle.origin.x - point.x
        let y = circle.origin.y - point.y
        
        let distance = sqrt( pow(x, 2) + pow(y, 2) )
        
        return distance < circle.radius
    }
    
    // MARK: - 绘图

    override public func drawRect(rect: CGRect) {
        if self.selectedButtons.isEmpty {
            return
        }
        
        let path: UIBezierPath = UIBezierPath()
        path.lineWidth = lineWidth
        path.lineJoinStyle = .Round
        
        lineColor.set()
        
        for (index, btn) in self.selectedButtons.enumerate() {
            if index == 0 {
                path.moveToPoint(btn.center)
            } else {
                path.addLineToPoint(btn.center)
            }
        }
        
        if self.currentPoint != nil {
            path.addLineToPoint(self.currentPoint!)
        }
        
        path.stroke()
    }
    
    // MARK: - 触摸方法
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let point = self.pointWith(touches) else {
            return
        }
        
        guard let btn = self.buttonWith(point) else {
            return
        }
        
        if btn.selected == false {
            btn.selected = true
            self.selectedButtons.append(btn)
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let point = self.pointWith(touches) else {
            return
        }
        
        if let btn = self.buttonWith(point) {
            if btn.selected == false {
                btn.selected = true
                self.selectedButtons.append(btn)
            }
        }
        
        self.currentPoint = point
        
        self.setNeedsDisplay()
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.delegate != nil {
            var path = String()
            self.selectedButtons.forEach { (btn: UIButton) -> () in
                path = path.stringByAppendingFormat("%d", btn.tag)
            }
            self.delegate!.lockView(self, didFinishPath: path)
        }
        
        //清空按钮
        self.selectedButtons.forEach { (btn: UIButton) -> () in
            btn.selected = false
        }
        
        self.selectedButtons.removeAll()
        
        self.setNeedsDisplay()
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.touchesEnded(((touches == nil) ? touches! : Set<UITouch>()), withEvent: event)
    }

}
