//
//  Graph.swift
//  SwiftGeometry
//
//  Created by Srinija on 15/09/17.
//  Copyright © 2017 Srinija. All rights reserved.
//

import UIKit

class Graph: UIView {
    
    public var chartTransform: CGAffineTransform?
    
    @IBInspectable var axisColor: UIColor = UIColor.black
    @IBInspectable var showInnerLines: Bool = true
    @IBInspectable var labelFontSize: CGFloat = 10
    
    var axisLineWidth: CGFloat = 1
    var deltaX: CGFloat = 10 // The change between each tick on the x axis
    var deltaY: CGFloat = 10 // and y axis
    var xMax: CGFloat = 100
    var yMax: CGFloat = 100
    var xMin: CGFloat = 0
    var yMin: CGFloat = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        combinedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        combinedInit()
    }
    
    func combinedInit() {
        yMax = xMax * (bounds.height/bounds.width)
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
        layer.borderWidth = 1
        layer.borderColor = axisColor.cgColor
        
    }
    
    
    
    func setTransform(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        
        let xOffset:CGFloat = 20.0
        let yOffset:CGFloat = 20.0
        
        let xScale = (bounds.width - yOffset - 10)/(maxX - minX)
        let yScale = ((bounds.height - xOffset - 30) - (bounds.height - xOffset - 30).truncatingRemainder(dividingBy: 10))/(maxY - minY)
        
        chartTransform = CGAffineTransform(a: xScale, b: 0, c: 0, d: -yScale, tx: yOffset, ty: bounds.height - xOffset)
        
        setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let t = chartTransform else { return }
        drawAxes(in: context, usingTransform: t)
    }
    
    public func setAxisRange() {
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
    }
    
    
    
    func drawAxes(in context: CGContext, usingTransform t: CGAffineTransform) {
        context.saveGState()
        
        // make two paths, one for thick lines, one for thin
        let thickerLines = CGMutablePath()
        let thinnerLines = CGMutablePath()
        
        // the two line chart axes
        let xAxisPoints = [CGPoint(x: xMin, y: 0), CGPoint(x: xMax, y: 0)]
        let yAxisPoints = [CGPoint(x: 0, y: yMin), CGPoint(x: 0, y: yMax)]
        
        thickerLines.addLines(between: xAxisPoints, transform: t)
        thickerLines.addLines(between: yAxisPoints, transform: t)
        
        for x in stride(from: xMin, through: xMax, by: deltaX) {
            
            let tickPoints = showInnerLines ?
                [CGPoint(x: x, y: yMin).applying(t), CGPoint(x: x, y: yMax).applying(t)] :
                [CGPoint(x: x, y: 0).applying(t), CGPoint(x: x, y: 0).applying(t).adding(y: -5)]
            
            
            thinnerLines.addLines(between: tickPoints)
            
            if x != xMin {  // draw the tick label (it is too buy if you draw it at the origin for both x & y
                let label = "\(Int(x))" as NSString // Int to get rid of the decimal, NSString to draw
                let labelSize = "\(Int(x))".size(withSystemFontSize: labelFontSize)
                let labelDrawPoint = CGPoint(x: x, y: 0).applying(t)
                    .adding(x: -labelSize.width/2)
                    .adding(y: 1)
                
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSFontAttributeName: UIFont.systemFont(ofSize: labelFontSize),
                     NSForegroundColorAttributeName: axisColor])
            }
        }
        // repeat for y
        for y in stride(from: yMin, through: yMax, by: deltaY) {
            
            let tickPoints = showInnerLines ?
                [CGPoint(x: xMin, y: y).applying(t), CGPoint(x: xMax, y: y).applying(t)] :
                [CGPoint(x: 0, y: y).applying(t), CGPoint(x: 0, y: y).applying(t).adding(x: 5)]
            
            
            thinnerLines.addLines(between: tickPoints)
            
            if y != yMin {
                let label = "\(Int(y))" as NSString
                let labelSize = "\(Int(y))".size(withSystemFontSize: labelFontSize)
                let labelDrawPoint = CGPoint(x: 0, y: y).applying(t)
                    .adding(x: -labelSize.width - 1)
                    .adding(y: -labelSize.height/2)
                
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSFontAttributeName: UIFont.systemFont(ofSize: labelFontSize),
                     NSForegroundColorAttributeName: axisColor])
            }
        }
        context.setStrokeColor(axisColor.cgColor)
        context.setLineWidth(axisLineWidth)
        context.addPath(thickerLines)
        context.strokePath()
        
        context.setStrokeColor(axisColor.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(axisLineWidth/2)
        context.addPath(thinnerLines)
        context.strokePath()
        
        context.restoreGState()
    }
    
    
    
}
