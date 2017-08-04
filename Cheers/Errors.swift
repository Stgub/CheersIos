//
//  Errors.swift
//  Cheers
//
//  Created by Charles Fayal on 8/3/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation

struct GeneralError:Error{
    var localizedDescription: String
}

struct userError:Error{
    var localizedDescription: String
}
