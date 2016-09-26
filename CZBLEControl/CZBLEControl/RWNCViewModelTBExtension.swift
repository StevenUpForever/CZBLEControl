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
    
    func rowNum(_ section: Int) -> Int {
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
    
    func cellText(_ cell: UITableViewCell, indexPath: IndexPath) {
        if identifier == .write {
            switch (indexPath as NSIndexPath).section {
            case 0:
                cell.textLabel?.text = descriptorArray[(indexPath as NSIndexPath).row]
                
            case 1:
                cell.textLabel?.text = writeValueArray[(indexPath as NSIndexPath).row].0
                
                //Show date label text
                cell.detailTextLabel?.text = writeValueArray[(indexPath as NSIndexPath).row].1
                
            case 2:
                cell.textLabel?.text = valueArray[(indexPath as NSIndexPath).row].0
                
                //Show date label text
                cell.detailTextLabel?.text = valueArray[(indexPath as NSIndexPath).row].1
                
            default:
                break
            }
        } else {
            switch (indexPath as NSIndexPath).section {
            case 0:
                cell.textLabel?.text = descriptorArray[(indexPath as NSIndexPath).row]
                
            case 1:
                cell.textLabel?.text = valueArray[(indexPath as NSIndexPath).row].0
                
                //Show date label text
                cell.detailTextLabel?.text = valueArray[(indexPath as NSIndexPath).row].1
                
            default:
                break
            }
        }
    }
    
    func deleteObjectAtIndexPath(_ indexPath: IndexPath) {
        if identifier == .write {
            switch (indexPath as NSIndexPath).section {
            case 1:
                writeValueArray.remove(at: (indexPath as NSIndexPath).row)
                
            case 2:
                valueArray.remove(at: (indexPath as NSIndexPath).row)
                
            default:
                break
            }
        } else {
            switch (indexPath as NSIndexPath).section {
            case 1:
                valueArray.remove(at: (indexPath as NSIndexPath).row)
                
            default:
                break
            }
        }
    }
    
    func dateFormatTransfer() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
        return dateFormatter.string(from: Date())
    }
    
    func sectionTitle(_ section: Int) -> String {
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
