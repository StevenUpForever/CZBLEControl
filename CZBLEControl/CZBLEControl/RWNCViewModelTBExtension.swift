//
//  RWNCViewModelTBExtension.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/5/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit

extension RWNCViewModel {
    
    func sectionNum() -> Int {
        if identifier == .write {
            return 3
        } else {
            return 2
        }
    }
    
    func rowNum(section: Int) -> Int {
        if identifier == .write {
            switch section {
            case 0:
                return descriptorArray.count
            case 1:
                return writeValueArray.count
            default:
                return valueArray.count
            }
        } else {
            return section == 0 ? descriptorArray.count : valueArray.count
        }
    }
    
    func cellText(cell: UITableViewCell, indexPath: NSIndexPath) {
        if identifier == .write {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = descriptorArray[indexPath.row]
                
            case 1:
                cell.textLabel?.text = writeValueArray[indexPath.row].0
                
                //Show date label text
                cell.detailTextLabel?.text = writeValueArray[indexPath.row].1
                
            case 2:
                cell.textLabel?.text = valueArray[indexPath.row].0
                
                //Show date label text
                cell.detailTextLabel?.text = valueArray[indexPath.row].1
                
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = descriptorArray[indexPath.row]
                
            case 1:
                cell.textLabel?.text = valueArray[indexPath.row].0
                
                //Show date label text
                cell.detailTextLabel?.text = valueArray[indexPath.row].1
                
            default:
                break
            }
        }
    }
    
    func deleteObjectAtIndexPath(indexPath: NSIndexPath) {
        if identifier == .write {
            switch indexPath.section {
            case 1:
                writeValueArray.removeAtIndex(indexPath.row)
                
            case 2:
                valueArray.removeAtIndex(indexPath.row)
                
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 1:
                valueArray.removeAtIndex(indexPath.row)
                
            default:
                break
            }
        }
    }
    
    func dateFormatTransfer() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
        return dateFormatter.stringFromDate(NSDate())
    }
    
    func sectionTitle(section: Int) -> String {
        if identifier == .write {
            switch section {
            case 0:
                return "Descriptors"
            case 1:
                return "Write Value"
            default:
                return "Return Value"
            }
            
        } else {
            if section == 0 {
                return "Descriptors"
            } else {
                switch identifier {
                case .read:
                    return "Read Value"
                case .writeWithNoResponse:
                    return "Write Value, no response"
                case .notify:
                    return "Return Value"
                default:
                    return "Invalid data type"
                }
            }
        }
    }
    
    func dataExisted() -> Bool {
        if identifier == .write {
            return writeValueArray.count != 0 || valueArray.count != 0
        } else {
            return valueArray.count != 0
        }
    }
    
}
