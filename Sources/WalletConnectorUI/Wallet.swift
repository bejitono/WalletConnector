//
//  Wallet.swift
//  
//
//  Created by Stefano on 17.04.21.
//

import Foundation

struct Wallet {
    let id: String
    let name: String
    let deeplinkBaseURL: URL?
    let iconName: String
}

extension Wallet: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case deeplinkBaseURL
        case iconName
        case mobile
    }
    
    enum MobileKeys: String, CodingKey {
        case native
        case universal
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        
        let mobile = try values.nestedContainer(keyedBy: MobileKeys.self, forKey: .mobile)
        let deeplinkBaseURLString = try mobile.decode(String.self, forKey: .native)
        deeplinkBaseURL = URL(string: deeplinkBaseURLString)
        
        iconName = try values.decode(String.self, forKey: .id)
    }
}
