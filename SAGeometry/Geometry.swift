//
//  Geometry.swift
//  SwiftGeometry
//
//  Created by Srinija on 09/09/17.
//  Copyright © 2017 Srinija. All rights reserved.
//

import UIKit

class Geometry: NSObject {
    
    static let instance = Geometry()
    let decimalPlaces = 3
    
    //MARK: Points
    func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat{
        let xPow = pow((point1.x - point2.x), 2)
        let yPow = pow((point1.y - point2.y), 2)
        return CGFloat(sqrt(Double(xPow + yPow)))
    }
    
    func reorderToConvexQuadrilateral(corners:[CGPoint]) -> ([CGPoint]?){
        if(isConcave(corners:corners) == true){
            return nil
        }
        if(isConvex(corners:corners) == true){
            return corners
        }
        
        var low = corners[0]
        var high = low;
        for point in corners{
            low.x = min(point.x, low.x);
            low.y = min(point.y, low.y);
            high.x = max(point.x, high.x);
            high.y = max(point.y, high.y);
        }
        
        let center = CGPoint(x: (low.x + high.x)/2,y: (low.y + high.y)/2)
        
        func angleFromPoint(point: CGPoint) -> Float{
            let theta = (Double)(atan2f((Float)(point.y - center.y), (Float)(point.x - center.x)))
            return fmodf((Float)(Double.pi - Double.pi/4 + theta), (Float)(2.0 * Double.pi))
        }
        
        let sortedArray = corners.sorted(by: {  (p1, p2)  in
            return angleFromPoint(point: p1) < angleFromPoint(point: p2)
        })
        
        return(sortedArray)
        
    }
    
    /**
     Returns a CGRect if possible. Nil otherwise.
     */
    func getCGRectFromPoints(topLeft: CGPoint,topRight: CGPoint,bottomRight: CGPoint,bottomLeft: CGPoint) -> CGRect?{
        let corners = [topLeft,topRight,bottomRight,bottomLeft]
        
        if(isQuadrilateralRectangle(corners: corners)){
            let width = distanceBetweenPoints(point1: topLeft, point2: topRight)
            let height = distanceBetweenPoints(point1: topLeft, point2: bottomLeft)
            return CGRect(origin: topLeft, size: CGSize(width: width, height: height))
        }
        return nil
        
    }
    
    
    func isConvex(topLeft: CGPoint,topRight: CGPoint,bottomRight: CGPoint,bottomLeft: CGPoint)-> Bool{
        
        if(isOppositeSidesOfLine(p1: topRight,p2: bottomLeft,l1: topLeft,l2: bottomRight) && isOppositeSidesOfLine(p1: topLeft,p2: bottomRight,l1: topRight,l2: bottomLeft)){
            return true
        }
        return false
    }
    
    func isConcave(topLeft: CGPoint,topRight: CGPoint,bottomRight: CGPoint,bottomLeft: CGPoint)-> Bool{
        
        let first = isOppositeSidesOfLine(p1: topRight,p2: bottomLeft,l1: topLeft,l2: bottomRight)
        let second = isOppositeSidesOfLine(p1: topLeft,p2: bottomRight,l1: topRight,l2: bottomLeft)
        if(first != second){
            return true
        }
        return false
    }
    
    
    
    func isConvex(corners:[CGPoint]) -> Bool{
        return isConvex(topLeft: corners[0], topRight: corners[1], bottomRight: corners[2], bottomLeft: corners[3])
    }
    
    func isConcave(corners:[CGPoint]) -> Bool{
        return isConcave(topLeft: corners[0], topRight: corners[1], bottomRight: corners[2], bottomLeft: corners[3])
    }
    
    func isQuadrilateralRectangle(corners:[CGPoint]) -> Bool{
        var corners = corners
        if(isConcave(corners: corners)){
            return false
        }
        if(!isConvex(corners: corners)){
            corners = reorderToConvexQuadrilateral(corners:corners)!
        }
        if(equal(getAngleBetweenPoints(p1: corners[0], p2: corners[1], p3: corners[2]),.pi/2) &&
            equal(getAngleBetweenPoints(p1: corners[1], p2: corners[2], p3: corners[3]),.pi/2) &&
            equal(getAngleBetweenPoints(p1: corners[2], p2: corners[3], p3: corners[0]),.pi/2)){
            return true
        }
        
        return false
    }
    
    func isQuadrilateralSquare(corners:[CGPoint]) -> Bool {
        if(isQuadrilateralRhombus(corners: corners) && isQuadrilateralRectangle(corners: corners)){
            return true
        }
        return false
    }
    
    func isQuadrilateralRhombus(corners:[CGPoint]) -> Bool {
        if(corners.count != 4){
            return false
        }
        if(corners[0] == corners[1]){
            return false
        }
        let distance = distanceBetweenPoints(point1: corners[0], point2: corners[1])
        
        if(distanceBetweenPoints(point1: corners[1], point2: corners[2]) != distance || distanceBetweenPoints(point1: corners[2], point2: corners[3]) != distance || distanceBetweenPoints(point1: corners[3], point2: corners[0]) != distance){
            return false
        }
        return true
    }
    
    func arePointsCollinear(points:[CGPoint]) -> Bool {
        if(points.count < 3){
            return true
        }
        let p1 = points[0]
        var p2 = CGPoint()
        var j = 1
        for i in 1 ... points.count{
            p2 = points[i]
            if(p1 != p2){
                break
            }
            j = i
        }
        if(p2 == p1){
            return true
        }
        
        
        if(p2.x == p1.x){
            for i in j ... points.count{
                let p3 = points[i]
                if(p3.x != p2.x){
                    return false
                }
            }
            return true
        }
        
        let slope = (p1.y - p2.y) / (p1.x - p2.x)
        for i in j...points.count {
            let p3 = points[i]
            if(p3.x == p2.x ){
                if(points[i].y != p2.y){
                    return false
                }
                continue
            }
            let slope2 = (p3.y - p2.y)/(p3.x - p2.x)
            if(!equal(slope,slope2)){
                return false
            }
        }
        return true
    }
    
    func isPointInsideTriangle(point:CGPoint, vertices:[CGPoint]) -> Bool? {
        if(!isTriangle(points: vertices)){
            return nil
        }
        if(equal(areaOfTriangle(vertices: [vertices[0],vertices[1],point]) +
            areaOfTriangle(vertices: [vertices[1],vertices[2],point]) +
            areaOfTriangle(vertices: [vertices[2],vertices[0],point]),
                 areaOfTriangle(vertices: [vertices[0],vertices[1],vertices[2]]))
            ){
            return true
        }
        return false
        
    }
    
    func areaOfTriangle(vertices:[CGPoint]) -> CGFloat {
        if(!isTriangle(points:vertices)){return 0}
        let A = vertices[0]
        let B = vertices[1]
        let C = vertices[2]
        
        return abs((A.x*(B.y - C.y) + B.x*(C.y - A.y) + C.x*(A.y - B.y))/2)
    }
    
    func isTriangle(points:[CGPoint]) -> Bool{
        return points.count == 3 && points[0] != points[1] && points[1] !=  points[2] && points[2] != points[0]
    }
    
    func isQuadrilateral(points:[CGPoint]) -> Bool {
        return points.count == 4 && points[0] != points[1] && points[1] !=  points[2] && points[2] != points[0] && points[3] != points[0]
    }
    
    func isPointOnLine(point:CGPoint, l1:CGPoint, l2:CGPoint) -> Bool{
        if(l1 == l2){
            return true
        }
        if(equal(distanceBetweenPoints(point1: point, point2: l1) + distanceBetweenPoints(point1: point, point2: l2), distanceBetweenPoints(point1: l1, point2: l2))){
            return true
        }
        return false
        
    }
    
    func isPointOnTriangle(point:CGPoint, vertices:[CGPoint]) -> Bool{
        if(isPointOnLine(point: point, l1: vertices[0], l2: vertices[1]) || isPointOnLine(point: point, l1: vertices[0], l2: vertices[1]) || isPointOnLine(point: point, l1: vertices[0], l2: vertices[1])){
            return true
        }
        return false
    }
    
    func isPointOnPolygon(point:CGPoint, corners:[CGPoint]) -> Bool{
        if(isPointOnLine(point: point, l1: corners[0], l2: corners[1]) || isPointOnLine(point: point, l1: corners[0], l2: corners[1]) || isPointOnLine(point: point, l1: corners[1], l2: corners[2]) || isPointOnLine(point: point, l1: corners[3], l2: corners[0]) ){
            return true
        }
        return false
    }
    
    
    func isPointInsideCircle(point:CGPoint, center:CGPoint, radius:CGFloat) -> Bool {
        if(distanceBetweenPoints(point1: point, point2: center) < radius){
            return true
        }
        return false
    }
    
    
    func isPointOnCircle(point:CGPoint, center:CGPoint, radius:CGFloat) -> Bool {
        if(equal(distanceBetweenPoints(point1: point, point2: center), radius)){
            return true
        }
        return false
    }
    
    
    func shortestDistanceBetweenLineAndPoint(point:CGPoint, l1:CGPoint, l2:CGPoint) -> CGFloat {
        let A = point.x - l1.x
        let B = point.y - l1.y
        let C = l2.x - l1.x
        let D = l2.y - l1.y
        
        let dotProduct = A * C + B * D
        let lenSquared = C * C + D * D
        
        var param : CGFloat = -1
        if(lenSquared != 0){
            param = dotProduct/lenSquared
        }
        
        var x, y :CGFloat
        
        if(param < 0){
            x = l1.x
            y = l1.y
        }else if(param > 1){
            x = l2.x
            y = l2.y
        }else {
            x = l1.x + param * C;
            y = l1.y + param * D;
        }
        
        let dx = point.x - x
        let dy = point.y - y
        
        return getTruncated(sqrt(dx*dx + dy*dy))
        
        
    }
    
    
    
    func getAngleBetweenPoints(p1:CGPoint, p2: CGPoint, p3:CGPoint) -> Double{
        
        //        let d12 = pow(p1.x - p2.x,2) + pow(p1.y - p2.y, 2)
        //        let d23 = pow(p2.x - p3.x,2) + pow(p2.y - p3.y, 2)
        //        let d31 = pow(p3.x - p1.x,2) + pow(p3.y - p1.y, 2)
        
        let d12 = distanceBetweenPoints(point1: p1, point2: p2)
        let d23 = distanceBetweenPoints(point1: p2, point2: p3)
        let d31 = distanceBetweenPoints(point1: p3, point2: p1)
        
        if(equal(d12,0) || equal(d23,0)){
            return 0
        }
        let numerator = d12*d12 + d23*d23 - d31*d31
        let denominator = 2 * d12 * d23
        return acos(Double(numerator/denominator))
        
    }
    
    func getAngleBetweenPointsInDegrees(p1:CGPoint, p2: CGPoint, p3:CGPoint) -> Double{
        return getAngleBetweenPoints(p1: p1,p2: p2,p3: p3) * 180/Double.pi
    }
    
    //MARK: Lines
    
    private func isOppositeSidesOfLine(p1:CGPoint, p2: CGPoint, l1: CGPoint, l2:CGPoint) -> Bool{
        let part1 = (l1.y-l2.y)*(p1.x-l1.x) + (l2.x-l1.x)*(p1.y-l1.y)
        let part2 = (l1.y-l2.y)*(p2.x-l1.x) + (l2.x-l1.x)*(p2.y-l1.y)
        if((part1*part2) < 0){
            return true
        }else{
            return false
        }
    }
    
    func arePointsOnSameSideOfLine(p1:CGPoint, p2:CGPoint, l1:CGPoint, l2:CGPoint) -> Bool {
        let part1 = (l1.y-l2.y)*(p1.x-l1.x) + (l2.x-l1.x)*(p1.y-l1.y)
        let part2 = (l1.y-l2.y)*(p2.x-l1.x) + (l2.x-l1.x)*(p2.y-l1.y)
        if((part1*part2) > 0){
            return true
        }else{
            return false
        }
    }
    
    private func equal(_ value1:CGFloat, _ value2:CGFloat) -> Bool{
        let divisor:CGFloat = CGFloat(pow(10.0, Double(decimalPlaces)))
        
        let v1 = Double((divisor*value1).rounded()/divisor)
        let v2 = Double((divisor*value2).rounded()/divisor)
        return v1 == v2
    }
    private func equal(_ value1:Double, _ value2:Double) -> Bool{
        let divisor:Double = Double(pow(10.0, Double(decimalPlaces)))
        
        let v1 = Double((divisor*value1).rounded()/divisor)
        let v2 = Double((divisor*value2).rounded()/divisor)
        return v1 == v2
    }
    
    private func getTruncated(_ value:CGFloat) -> CGFloat{
        return CGFloat((1000*value).rounded()/1000)
    }
    // func shortestDistanceBetweenTwoLines
    
    
    private func collinearPointOnSegment(point:CGPoint, l1:CGPoint, l2: CGPoint) -> Bool {
        if(point.x <= max(l1.x, l2.x) && point.x >= min(l1.x, l2.x) && point.y <= max(l1.y, l2.y) && point.y >= min(l1.y, l2.y)){
            return true
        }
        return false
    }
    
    //Orientation of an ordered triplets
    func orientationOfPoints(p1: CGPoint, p2: CGPoint, p3:CGPoint) -> Int{
        var A = (p2.y - p1.y) * (p3.x - p2.x)
        var B = (p2.x - p1.x) * (p3.y - p2.y)
        if(A.isNaN){
            let inf = CGFloat.infinity
            if(p2.y == inf || p2.x == inf || p2.y == -inf || p2.x == -inf){
                A = CGFloat.infinity
            }else if(p2.y == -inf || p2.x == -inf || p2.y == inf || p2.x == inf){
                A = -CGFloat.infinity
            }
        }
        if(B.isNaN){
            let inf = CGFloat.infinity
            if(p2.x == inf || p3.y == inf || p1.x == -inf || p2.y == -inf){
                B = CGFloat.infinity
            }else if(p2.x == -inf || p3.y == -inf || p1.x == inf || p2.y == inf){
                B = -CGFloat.infinity
            }
        }
        
        let diffSlope =  A - B
        if(diffSlope == 0) { return 0 }
        return diffSlope > 0 ? 1 : -1
        
    }
    
    
    func doLineSegmentsIntersect(l1:CGPoint, l2:CGPoint, m1:CGPoint, m2:CGPoint) -> Bool{
        let orient1 = orientationOfPoints(p1: l1, p2: l2, p3: m1);
        let orient2 = orientationOfPoints(p1: l1, p2: l2, p3: m2);
        let orient3 = orientationOfPoints(p1: m1, p2: m2, p3: l1);
        let orient4 = orientationOfPoints(p1: m1, p2: m2, p3: l2);
        
        if(orient1 != orient2 && orient3 != orient4){
            return true
        }
        
        if(orient1 == 0 && collinearPointOnSegment(point: m1, l1: l1, l2: l2)){ return true }
        if(orient2 == 0 && collinearPointOnSegment(point: l1, l1: m1, l2: m2)){ return true }
        if(orient3 == 0 && collinearPointOnSegment(point: m2, l1: l1, l2: l2)){ return true }
        if(orient4 == 0 && collinearPointOnSegment(point: l2, l1: m1, l2: m2)){ return true }
        
        return false
        
    }
    
    func isPointInsidePolygon(point:CGPoint, polygon:[CGPoint]) -> Bool {
        if(polygon.count < 3){
            return false
        }
        
        let inf = CGPoint(x: Double.infinity, y: Double(point.y))
        var count = 0
        
        for i in 0...(polygon.count - 1) {
            let j = (i+1)%polygon.count
            
            if(doLineSegmentsIntersect(l1: point, l2: inf, m1: polygon[i], m2: polygon[j])){
                
                if(orientationOfPoints(p1: polygon[i], p2: point, p3: polygon[j]) == 0){
                    return collinearPointOnSegment(point: point, l1: polygon[i], l2: polygon[j])
                }
                
                count = count + 1
            }
        }
        return(count%2 == 1)
    }
    
    
    
    //    func projectionOfPointOnLine(point:CGPoint, l1:CGPoint, l2:CGPoint)->CGPoint{
    //        return CGPoint()
    //    }
    //
    //    func mirrorPointOnLine(point:CGPoint, l1:CGPoint, l2:CGPoint)->CGPoint{
    //        return CGPoint()
    //    }
    //    
    //MARK: Circles
    
    
    
}
