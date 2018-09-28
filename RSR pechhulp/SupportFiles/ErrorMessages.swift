//
//  ErrorMessages.swift
//  RSR pechhulp
//
//  Created by Geart Otten on 27/09/2018.
//  Copyright © 2018 Geart Otten. All rights reserved.
//

import Foundation

class ErrorMessages {
    private static let errorMessages : [ErrorSituation:AlertParameters] =
        [.noGPSConnectionFound: (title: "GPS aanzetten", message:"U heeft deze app geen toegang gegeven voor GPS. Zet dit a.u.b aan in uw instellingen."),
         .noInternetConnectionFound: (title: "Geen internetverbinding", message:"Er is geen verbinding mogelijk met het ineternet. Hierdoor kunnen uw locatiegegevens niet opgehaald worden.")]
    
    subscript (situation : ErrorSituation) -> AlertParameters {
        return ErrorMessages.errorMessages[situation]!
    }
    
}
