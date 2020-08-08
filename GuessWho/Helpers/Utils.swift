//
//  Utils.swift
//  GuessWho
//
//  Created by Siraj Hamza on 2019-04-09.
//  Copyright © 2019 devHamza. All rights reserved.
//

import Foundation


func retrieveEnvVariable(for key: String) -> String {
    
    guard let envVariablesPath = Bundle.main.path(forResource: "EnvVariables", ofType: "plist"),
        
        let envVariables = NSDictionary(contentsOfFile: envVariablesPath) else {
            
            return "Not Found"
        }
    
    if let envVariable = envVariables[key] as? String {
        
        return envVariable
    }
    else {
        
        return "Not Found"
    }
}
