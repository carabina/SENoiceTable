//
//  NoiceTable.swift
//  Pods
//
//  Created by Sahand Edrisian on 8/25/16.
//
//

import UIKit


protocol NoiceTableDelegate {
    func CellTapped(row: Int) -> () -> Void
    func CellDismissed(row: Int) -> () -> Void
}


class NoiceTable: UIView {
    
    var cellWidth : CGFloat?
    
    var cellHeight : CGFloat?
    
    var cellNames : [String]?
    
    var cellAlignment : UIControlContentHorizontalAlignment?
    
    var cellEdgeInsets : UIEdgeInsets?
    
    var separatorColor : UIColor? { didSet { } }
    
    override var backgroundColor: UIColor? { didSet { } }
    
    var tableWidth : CGFloat?
    
    var tableHeight : CGFloat?
    
    var scrollView : UIScrollView?
    
    var tableView : UIView?
    
    var cells : [UIView]?
    
    var buttons = [UIButton]()
    
    var delegate : NoiceTableDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellWidth = frame.size.width
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func make() {
        
        createScrollView()
        createTableView()
        setEnvironmentProperties()
        makeTable()
    }
    
    func createScrollView() {
        
        scrollView = UIScrollView(frame: self.bounds)
        scrollView!.backgroundColor = UIColor.clearColor()
        scrollView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView!.contentOffset = CGPoint(x: 1000, y: 450)
        
        self.addSubview(scrollView!)
    }
    
    func createTableView() {
        tableView = UIView(frame: CGRectMake(0,0,self.frame.size.width,self.frame.size.height))
        scrollView!.contentSize = tableView!.bounds.size
        scrollView?.addSubview(tableView!)
    }
    
    func setEnvironmentProperties() {
        
        if let width = cellWidth {
            tableView?.frame.size.width = width
            scrollView!.contentSize = tableView!.bounds.size
        }
        if let width = tableWidth {
            tableView?.frame.size.width = width
            scrollView!.contentSize = tableView!.bounds.size
        }
        if let height = tableWidth {
            tableView?.frame.size.height = height
            scrollView!.contentSize = tableView!.bounds.size
        }
        if backgroundColor == nil {
            backgroundColor = UIColor.blackColor()
        }
        if separatorColor == nil {
            separatorColor = UIColor(hex: 0x21ce99)
        }
    }
    
    func makeTable() {
        if cellNames?.count > 0 {
            tableView!.subviews.forEach({ $0.removeFromSuperview() })
            //            var tempCellHeight = (tableView?.bounds.size.height)!/CGFloat((cellNames?.count)!)
            var tempCellHeight = CGFloat(60.0)
            
            if let height = cellHeight {
                tempCellHeight = height
            }
            
            for i in 0..<(cellNames?.count)! {
                let cellView = UIView(frame: CGRectMake(0,CGFloat(i)*tempCellHeight, cellWidth!, tempCellHeight))
                cellView.backgroundColor = backgroundColor
                cellView.tag = i
                tableView?.addSubview(cellView)
                
                let separatorView = UIView(frame: CGRectMake(28, tempCellHeight-2.0, cellWidth!, 1))
                separatorView.backgroundColor = separatorColor
                cellView.addSubview(separatorView)
                
                let cellButton = UIButton(frame: CGRectMake(0,0,cellWidth!,tempCellHeight))
                cellButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 15)
                cellButton.setTitle(cellNames![i], forState: .Normal)
                cellButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                cellButton.addTarget(self, action: #selector(cellTapped), forControlEvents: .TouchUpInside)
                cellButton.userInteractionEnabled = true
                cellButton.tag = i
                if let alignment = cellAlignment {
                    cellButton.contentHorizontalAlignment = alignment
                } else {
                    cellButton.contentHorizontalAlignment = .Left
                }
                if let edgeInsets = cellEdgeInsets {
                    cellButton.contentEdgeInsets = edgeInsets
                } else {
                    cellButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
                }
                cellView.addSubview(cellButton)
                buttons.append(cellButton)
            }
            
            tableView?.frame.size.height = tempCellHeight*CGFloat((cellNames?.count)!)
            
            scrollView!.contentSize = tableView!.bounds.size
            
        }
    }
    
    var prevLoc = CGPoint()
    var chosenView = UIView()
    var selectedButtonTag = 0
    var selectedMode = false
    var selectedCellPositionY = CGFloat()
    
    func cellTapped(sender: UIButton) {
        
        if !selectedMode {
            
            selectedMode = true
            
            let height = UIScreen.mainScreen().bounds.height
            
            selectedCellPositionY = (sender.superview?.frame.origin.y)!
            
            selectedButtonTag = sender.tag
            UIView.animateWithDuration(0.3, animations: {
                
                sender.superview?.frame.origin.y = (((40.0-32.0)/667.0)*height)+(self.scrollView?.contentOffset.y)!
                for btn in self.buttons {
                    if btn.tag != sender.tag {
                        btn.superview!.animateAlpha(0.0, t: 0.2)
                    }
                }
                self.chosenView = sender.superview!
                
                self.delegate?.CellTapped(sender.tag)()
                
            })
            
            scrollView?.scrollEnabled = false
            
        } else {
            
            selectedMode = false
            
            selectedButtonTag = sender.tag
            UIView.animateWithDuration(0.3, animations: {
                
                sender.superview?.frame.origin.y = self.selectedCellPositionY
                for btn in self.buttons {
                    if btn.tag != sender.tag {
                        btn.superview!.animateAlpha(1.0, t: 0.2)
                    }
                }
                self.chosenView = sender.superview!
                
                self.delegate?.CellDismissed(sender.tag)()
                
            })
            
            scrollView?.scrollEnabled = true
        }
    }
    
}



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}

extension UIView {
    
    func animateAlpha(a: CGFloat, t: Double) {
        UIView.animateWithDuration(t, animations: {
            self.alpha = a
        })
    }
}