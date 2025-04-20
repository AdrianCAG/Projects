//
//  ElectronicInstrument.swift
//  MedicalInstruments
//
//  Created by Adrian on 4/17/25.
//

import Foundation


class ElectronicInstrument: Instrument {
    private var hospital: Hospital
    
    
    init(_ hospital: Hospital) {
        self.hospital = hospital
    }
    
    func setHospital(_ hospital: Hospital) {
        if self.hospital === hospital {
            self.hospital = hospital
            hospital.addElectronicInstrument(self)
        }
    }
    
    var getHospital: Hospital {
        get {
            return hospital
        }
    }
    
    func printAddress() {
        let address = Unmanaged.passUnretained(self).toOpaque()
        print("Memory address of self: \(address)")
    }
}
