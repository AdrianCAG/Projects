//
//  SurgicalInstrument.swift
//  MedicalInstruments
//
//  Created by Adrian on 4/17/25.
//

import Foundation




class SurgicalInstrument: Instrument, CustomStringConvertible {
    private var hospital: Hospital
    
    init(_ hospital: Hospital) {
        self.hospital = hospital
    }
    
    func setHospital(_ hospital: Hospital) {
        if self.hospital === hospital {
            self.hospital = hospital;
            hospital.addSurgicalInstrument(self)
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
    
    var description: String {
        return "(\(hospital))"
    }

}
