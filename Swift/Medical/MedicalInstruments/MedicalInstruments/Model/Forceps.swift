//
//  Forceps.swift
//  MedicalInstruments
//
//  Created by Adrian on 4/17/25.
//

import Foundation


class Forceps: SurgicalInstrument {
    override init(_ hospital: Hospital) {
        super.init(hospital)
    }
    
    override func printAddress() {
        let address = Unmanaged.passUnretained(self).toOpaque()
        print("Memory address of self: \(address)")
    }
}
