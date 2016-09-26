//
//  DataPublicHeader.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/7/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation

let kFolderName = "CZBLEControl"

typealias statusMessageHandler = (_ success: Bool, _ errorMessage: String?) -> Void

func tupleJoinStr(_ dataArray: [(String, String)]) -> String {
    var result = ""
    for tuple in dataArray {
        result.append(tuple.0 + "\n" + tuple.1 + "\n\n")
    }
    return result
}
