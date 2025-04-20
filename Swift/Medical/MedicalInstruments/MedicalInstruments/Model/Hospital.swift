//
//  Hospital.swift
//  MedicalInstruments
//
//  Created by Adrian on 4/17/25.
//

import Foundation


class Hospital {
    private var surgicalInstruments: [SurgicalInstrument]
    private var electronicInstruments: [ElectronicInstrument]
    
    init(_ surgicalInstruments: [SurgicalInstrument], _ electronicInstruments: [ElectronicInstrument]) {
        self.surgicalInstruments = surgicalInstruments
        self.electronicInstruments = electronicInstruments
    }
    
    func addSurgicalInstrument(_ s: SurgicalInstrument) {
        if !surgicalInstruments.contains(where: { $0 === s }) {
            surgicalInstruments.append(s)
            s.setHospital(self)
        }
    }
    
    func addElectronicInstrument(_ e: ElectronicInstrument) {
        if !electronicInstruments.contains(where: { $0 === e }) {
            electronicInstruments.append(e)
            e.setHospital(self)
        }
    }
    
    var getSurgicalInstruments: [SurgicalInstrument] {
        get {
            return surgicalInstruments
        }
    }
    
    var getElectronicInstruments: [ElectronicInstrument] {
        get {
            return electronicInstruments
        }
    }
    
    func printAddress() {
        let address = Unmanaged.passUnretained(self).toOpaque()
        print("Memory address of self: \(address)")
    }
}
