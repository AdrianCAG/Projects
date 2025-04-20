//
//  main.swift
//  MedicalInstruments
//
//  Created by Adrian on 4/17/25.
//

import Foundation


func main() {
    let surgicalInstruments = [SurgicalInstrument]()
    let electronicInstruments = [ElectronicInstrument]()
    
    let hospital = Hospital(surgicalInstruments, electronicInstruments)
    
    
    let forceps = Forceps(hospital)
    let scalpel = Scalpel(hospital)
    let mri = MRI(hospital)
    let ultraSound = UltraSound(hospital)
    
    hospital.addElectronicInstrument(ultraSound)
    hospital.addElectronicInstrument(mri)
    hospital.addSurgicalInstrument(scalpel)
    hospital.addSurgicalInstrument(forceps)
    
    hospital.addSurgicalInstrument(forceps)
    
    
    for surgicalInstrument in hospital.getSurgicalInstruments {
        surgicalInstrument.printAddress()
    }
    
    print()
    
    for surgicalInstrument in ultraSound.getHospital.getSurgicalInstruments {
        surgicalInstrument.printAddress()
    }
    
    print("END")
    
}




main()
