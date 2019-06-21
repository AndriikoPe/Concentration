//
//  SetView.swift
//  Set
//
//  Created by Пермяков Андрей on 27.10.2018.
//  Copyright © 2018 Пермяков Андрей. All rights reserved.
//

import UIKit

//  Arranges the space in a rectangle into a grid of cells.
//  All cells will be exactly the same size.
//  If the grid does not fill the provided frame edge-to-edge
//    then it will center the grid of cells in the provided frame.
//  If you want spacing between cells in the grid, simply inset each cell's frame.
//
//  How it lays the cells out is determined by the layout property:
//  Layout can be done by (a) fixing the cell size
//    (Grid will create as many rows and columns as will fit)
//  Or (b) fixing the number of rows and columns
//    (Grid will make the cells as large as possible)
//  Or (c) ensuring a certain aspect ratio (width vs. height) for each cell
//    (Grid will make cellCount cells fit, making the cells as large as possible)
//    (you must set the cellCount var for the aspectRatio layout to know what to do)
//
//  The bounding rectangle of a cell in the grid is obtained by subscript (e.g. grid[11] or grid[1,5]).
//  The dimensions tuple will contain the number of (calculated or specified) rows and columns.
//  Setting aspectRatio, dimensions or cellSize, may change the layout.
//
//  To use, simply employ the initializer to choose a layout strategy and set the frame.
//  After creating a Grid, you can change the frame or layout strategy at any time
//    (all other properties will immediately update).
// 0.12 * height < width && width > height * 25 / 17

struct Grid
{
    enum Layout {
        case fixedCellSize(CGSize)
        case dimensions(rowCount: Int, columnCount: Int)
        case aspectRatio(CGFloat)
    }
    
    var layout: Layout { didSet { recalculate() } }
    
    var frame: CGRect { didSet { recalculate() } }
    
    init(layout: Layout, frame: CGRect = CGRect.zero) {
        self.frame = frame
        self.layout = layout
        recalculate()
    }
    
    subscript(row: Int, column: Int) -> CGRect? {
        return self[row * dimensions.columnCount + column]
    }
    
    subscript(index: Int) -> CGRect? {
        return index < cellFrames.count ? cellFrames[index] : nil
    }
    
    var cellCount: Int {
        get {
            switch layout {
            case .aspectRatio: return cellCountForAspectRatioLayout
            case .fixedCellSize, .dimensions: return calculatedDimensions.rowCount * calculatedDimensions.columnCount
            }
        }
        set { cellCountForAspectRatioLayout = newValue }
    }
    
    var cellSize: CGSize {
        get { return cellFrames.first?.size ?? CGSize.zero }
        set { layout = .fixedCellSize(newValue) }
    }
    
    var dimensions: (rowCount: Int, columnCount: Int) {
        get { return calculatedDimensions }
        set { layout = .dimensions(rowCount: newValue.rowCount, columnCount: newValue.columnCount) }
    }
    
    var aspectRatio: CGFloat {
        get {
            switch layout {
            case .aspectRatio(let aspectRatio):
                return aspectRatio
            case .fixedCellSize(let size):
                return size.height > 0 ? size.width / size.height : 0.0
            case .dimensions(let rowCount, let columnCount):
                if rowCount > 0 && columnCount > 0 && frame.size.width > 0 {
                    return (frame.size.width / CGFloat(columnCount)) / (frame.size.width / CGFloat(rowCount))
                } else {
                    return 0.0
                }
            }
        }
        set { layout = .aspectRatio(newValue) }
    }
    
    private var cellFrames = [CGRect]()
    private var cellCountForAspectRatioLayout = 0 { didSet { recalculate() } }
    private var calculatedDimensions: (rowCount: Int, columnCount: Int) = (0, 0)
    
    private mutating func recalculate() {
        switch layout {
        case .fixedCellSize(let cellSize):
            if cellSize.width > 0 && cellSize.height > 0 {
                calculatedDimensions.rowCount = Int(frame.size.height / cellSize.height)
                calculatedDimensions.columnCount = Int(frame.size.width / cellSize.width)
                updateCellFrames(to: cellSize)
            } else {
                assert(false, "Grid: for fixedCellSize layout, cellSize height and width must be positive numbers")
                calculatedDimensions = (0, 0)
                cellFrames.removeAll()
            }
        case .dimensions(let rowCount, let columnCount):
            if columnCount > 0 && rowCount > 0 {
                calculatedDimensions.rowCount = rowCount
                calculatedDimensions.columnCount = columnCount
                let cellSize = CGSize(width: frame.size.width/CGFloat(columnCount), height: frame.size.height/CGFloat(rowCount))
                updateCellFrames(to: cellSize)
            } else {
                assert(false, "Grid: for dimensions layout, rowCount and columnCount must be positive numbers")
                calculatedDimensions = (0, 0)
                cellFrames.removeAll()
            }
        case .aspectRatio:
            assert(aspectRatio > 0, "Grid: for aspectRatio layout, aspectRatio must be a positive number")
            let cellSize = largestCellSizeThatFitsAspectRatio()
            if cellSize.area > 0 {
                calculatedDimensions.columnCount = Int(frame.size.width / cellSize.width)
                calculatedDimensions.rowCount = (cellCount + calculatedDimensions.columnCount - 1) / calculatedDimensions.columnCount
            } else {
                calculatedDimensions = (0, 0)
            }
            updateCellFrames(to: cellSize)
            break
        }
    }
    
    private mutating func updateCellFrames(to cellSize: CGSize) {
        cellFrames.removeAll()
        
        let boundingSize = CGSize(
            width: CGFloat(dimensions.columnCount) * cellSize.width,
            height: CGFloat(dimensions.rowCount) * cellSize.height
        )
        let offset = (
            dx: (frame.size.width - boundingSize.width) / 2,
            dy: (frame.size.height - boundingSize.height) / 2
        )
        var origin = frame.origin
        origin.x += offset.dx
        origin.y += offset.dy
        
        if cellCount > 0 {
            for _ in 0..<cellCount {
                cellFrames.append(CGRect(origin: origin, size: cellSize).insetBy(dx: cellSize.width / 20, dy: cellSize.height / 20)) // added isnetBy()
                origin.x += cellSize.width
                if round(origin.x) > round(frame.maxX - cellSize.width) {
                    origin.x = frame.origin.x + offset.dx
                    origin.y += cellSize.height
                }
            }
        }
    }
    
    private func largestCellSizeThatFitsAspectRatio() -> CGSize {
        var largestSoFar = CGSize.zero
        if cellCount > 0 && aspectRatio > 0 {
            for rowCount in 1...cellCount {
                largestSoFar = cellSizeAssuming(rowCount: rowCount, minimumAllowedSize: largestSoFar)
            }
            for columnCount in 1...cellCount {
                largestSoFar = cellSizeAssuming(columnCount: columnCount, minimumAllowedSize: largestSoFar)
            }
        }
        return largestSoFar
    }
    
    private func cellSizeAssuming(rowCount: Int? = nil, columnCount: Int? = nil, minimumAllowedSize: CGSize = CGSize.zero) -> CGSize {
        var size = CGSize.zero
        if let columnCount = columnCount {
            size.width = frame.size.width / CGFloat(columnCount)
            size.height = size.width / aspectRatio
        } else if let rowCount = rowCount {
            size.height = frame.size.height / CGFloat(rowCount)
            size.width = size.height * aspectRatio
        }
        if size.area > minimumAllowedSize.area {
            if Int(frame.size.height / size.height) * Int(frame.size.width / size.width) >= cellCount {
                return size
            }
        }
        return minimumAllowedSize
    }
}






// the Grid object has ended

class SetView: UIView {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    var arrayOfCards = [[Int]]()
    private var hiddenViews = [Int]()
    var selectedCards = [Int]()
    
    override func draw(_ rect: CGRect) {
        let (rowCount, columnCount) = countRowsAndColumns()
        self.subviews.forEach {$0.removeFromSuperview()}
        let grid = Grid(layout: .dimensions(rowCount: rowCount, columnCount: columnCount), frame: bounds)
        for cell in 0..<grid.cellCount {
            let button = UIButton(frame: grid[cell]!)
            if let image = createAnImage(in: grid[cell]!, from: arrayOfCards[cell]) {
                button.setImage(image, for: UIControl.State.normal)
            }
            if hiddenViews.contains(cell) {
                button.alpha = 0
            }
            button.tag = cell
            if selectedCards.contains(cell) {
                button.layer.borderColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
                button.layer.borderWidth = 5.0
            }
            button.addTarget(SetViewController(), action: #selector(SetViewController.cardTouched), for: .touchUpInside)
            self.addSubview(button)
        }
        hiddenViews = [Int]()
    }
    
    func redrawView(withHiddenViews hiddenArray: [Int] = [Int]()) {
        hiddenViews = hiddenArray.count > 0 ? hiddenArray : [Int]()
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    
    enum casesOfAddingCards {
        case addingNewCards
        case replacingOldCard
        case removingCard
    }
    
    func removeCards(for array: [Int]) {
        for index in array {
            arrayOfCards.remove(at: index)
        }
        redrawView()
    }
    
    func addCard(withImage cardCode: SetCard, at index: Int, caseOfAdding: casesOfAddingCards) {
        var intedArrayOfCardCode = [Int]()
        intedArrayOfCardCode.append(cardCode.symbolNumber)
        intedArrayOfCardCode.append(cardCode.symbolColor)
        intedArrayOfCardCode.append(cardCode.symbolShape)
        intedArrayOfCardCode.append(cardCode.symbolShading)
        
        switch caseOfAdding {
        case .addingNewCards:
            arrayOfCards.append(intedArrayOfCardCode)
        case .removingCard:
            arrayOfCards.remove(at: index)
        case .replacingOldCard:
            arrayOfCards[index] = intedArrayOfCardCode
        }
    }
    
    func countRowsAndColumns() -> (Int, Int) {
        var arrayOfDividers = [Int]()
        let root = sqrt(Double(arrayOfCards.count))
        if root.rounded() == root {
            return (Int(root), Int(root))
        } else if arrayOfCards.count > 4 {
            for number in 2...arrayOfCards.count / 2 {
                if arrayOfCards.count % number == 0 {
                    arrayOfDividers.append(number)
                }
            }
        }
        let middleOfAnArray = (arrayOfDividers.count - 1) / 2
        let rows = arrayOfDividers[middleOfAnArray + 1]
        let columns = arrayOfDividers[middleOfAnArray]
        return (rows, columns)
    }
    
    
    func createAnImage (in rect: CGRect,from ints: [Int]) -> UIImage? { // TODO: landscape mode & nicer colors
        let width = rect.width, height = rect.height
        let numberOfSymbols = ints[0], symbolStyle = ints[3]
        var color = UIColor.clear
        switch ints[1] { //selecting a color for symbols
        case 1:
            color = UIColor.red
        case 2:
            color = UIColor.green
        case 3:
            color = UIColor.blue
        default:
            break
        }
        UIGraphicsBeginImageContext(rect.size)
        
        var path = UIBezierPath()
        
        func selectAStyle (_ style: Int) {
            switch style { // filling, stroking or stipping our path to finish it up
            case 1:
                color.setFill()
                path.fill()
            case 2:
                color.setStroke()
                path.lineWidth = 6.0
                path.stroke()
            case 3:
                color.setStroke()
                path.lineWidth = 4.0
                path.stroke()
                let context = UIGraphicsGetCurrentContext()!
                context.saveGState()
                path.lineWidth = 2.0
                path.addClip()
                path.move(to: CGPoint.zero)
                path.addLine(to: CGPoint(x: width, y: height))
                path.move(to: CGPoint(x: width / 5, y: 0))
                path.addLine(to: CGPoint(x: width, y: height * 4 / 5))
                path.move(to: CGPoint(x: width * 2 / 5, y: 0))
                path.addLine(to: CGPoint(x: width, y: height * 3 / 5))
                path.move(to: CGPoint(x: 0, y: height / 5))
                path.addLine(to: CGPoint(x: width * 4 / 5, y: height))
                path.move(to: CGPoint(x: 0, y: height * 2 / 5))
                path.addLine(to: CGPoint(x: width * 3 / 5, y: height))
                path.stroke()
                context.restoreGState()
            default:
                break
            }
        }
        //        if width < height {
        switch ints[2] { //selecting symbol shape
        case 1: // rectangle
            switch numberOfSymbols {
            case 1:
                let side = sqrt(width * height * 0.4)
                let xOffset = (width - side) / 2, yOffset = (height - side) / 2
                path = UIBezierPath(rect: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            case 2:
                let side = sqrt(width * height * 0.15)
                let xOffset = (width - side) / 2, yOffset = (height - 2*side) / 3
                path = UIBezierPath(rect: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = UIBezierPath(rect: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 2*yOffset + side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            case 3:
                let side = sqrt(width * height * 0.08)
                let xOffset = (width - side) / 2, yOffset = (height - 3*side) / 4
                path = UIBezierPath(rect: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = UIBezierPath(rect: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 2*yOffset + side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = UIBezierPath(rect: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 3*yOffset + 2*side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            default:
                break
            }
        case 2: //circle
            switch numberOfSymbols {
            case 1:
                let side = sqrt(width * height * 0.4)
                let xOffset = (width - side) / 2, yOffset = (height - side) / 2
                path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            case 2:
                let side = sqrt(width * height * 0.15)
                let xOffset = (width - side) / 2, yOffset = (height - 2*side) / 3
                path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 2*yOffset + side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            case 3:
                let side = sqrt(width * height * 0.1)
                let xOffset = (width - side) / 2, yOffset = (height - 3*side) / 4
                path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 2*yOffset + side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 3*yOffset + 2*side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            default:
                break
            }
        case 3: // triangle
            switch numberOfSymbols {
            case 1:
                let side = sqrt(width * height * 0.3)
                let xOffset = (width - side) / 2, yOffset = (height - side) / 2
                path = makeATriangleInARect(CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            case 2:
                let side = sqrt(width * height * 0.12)
                let xOffset = (width - side) / 2, yOffset = (height - 2*side) / 3
                path = makeATriangleInARect(CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = makeATriangleInARect(CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 2*yOffset + side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            case 3:
                let side = sqrt(width * height * 0.08)
                let xOffset = (width - side) / 2, yOffset = (height - 3*side) / 4
                path = makeATriangleInARect(CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: yOffset), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = makeATriangleInARect(CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 2*yOffset + side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
                path = makeATriangleInARect(CGRect(origin: CGPoint.zero.offsetBy(dx: xOffset, dy: 3*yOffset + 2*side), size: CGSize(width: side, height: side)))
                selectAStyle(symbolStyle)
            default:
                break
            }
        default:
            break
        }
        //        }
        //        else {
        //            return nil
        //        }
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

func makeATriangleInARect (_ rect: CGRect) -> UIBezierPath {
    let path = UIBezierPath()
    
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
    path.close()
    
    return path
}

private extension CGSize {
    var area: CGFloat {
        return width * height
    }
}

private extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

