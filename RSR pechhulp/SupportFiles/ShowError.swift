//
//  ShowError.swift
//  RSR pechhulp
//
//  Created by Geart Otten on 27/09/2018.
//  Copyright © 2018 Geart Otten. All rights reserved.
//

/// ErrorSituation Which error situation did the user get into and which error should the application be showing.
enum ErrorSituation {
    /// noGPSConnectionFound The user did not accept the GPS request or turned it off in the settings.
    case noGPSConnectionFound
    
    /// noInternetConnectionFound The device this application is running on does not have an active network connection
    case noInternetConnectionFound
}
