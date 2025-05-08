// SmartHomeFacadePatternApp - Demonstrates the Facade Design Pattern
// A medium-high complexity implementation for smart home automation

import Foundation

print("===== Smart Home Facade Pattern Demo =====\n")

// Create the Smart Home Facade
// The facade provides a simplified interface to the complex subsystems
let smartHome = SmartHomeFacade()

print("\n=== Demonstrating the Facade Pattern ===\n")
print("The Facade Pattern provides a simplified interface to a complex set of subsystems.")
print("Instead of interacting with multiple complex subsystems directly, we use the facade as a single point of interaction.")
print("This hides the complexities of the subsystems and makes the client code much simpler.\n")

// Get the initial home status
print("\n=== Initial Home Status ===\n")
print(smartHome.getHomeStatus())

// Demonstrate scene activation using the facade
print("\n=== Activating Morning Scene ===\n")
print("Instead of configuring each subsystem individually, we simply tell the facade to set the scene.")
smartHome.setScene(.morning)

// Show how the facade simplifies leaving home
print("\n=== Leaving Home ===\n")
print("The facade handles all the complexity of securing your home when you leave.")
smartHome.leaveHome()

// Show how the facade simplifies returning home
print("\n=== Returning Home ===\n")
print("The facade handles all the complexity of preparing your home when you return.")
smartHome.arriveHome()

// Demonstrate movie night scene
print("\n=== Setting Up for Movie Night ===\n")
print("The facade coordinates all systems to create the perfect movie watching environment.")
smartHome.setScene(.movie)

// Demonstrate going to bed
print("\n=== Going to Bed ===\n")
print("The facade prepares all systems for bedtime with a single command.")
smartHome.goToBed()

// Show direct subsystem access when needed
print("\n=== Direct Subsystem Access When Needed ===\n")
print("While the facade simplifies most interactions, you can still access subsystems directly when needed:")

// Get direct access to the lighting system for a specific task
let lightingSystem = smartHome.getLightingSystem()
if let bedroomGroup = lightingSystem.getGroup(withId: "G003") {
    print("\nDirectly controlling bedroom lights through the lighting subsystem:")
    bedroomGroup.turnAllOn()
    bedroomGroup.setAllBrightness(30)
}

// Get final home status
print("\n=== Final Home Status ===\n")
print(smartHome.getHomeStatus())

print("\n===== End of Facade Pattern Demo =====\n")
print("This application demonstrates how the Facade Pattern simplifies interaction with complex subsystems")
print("by providing a unified interface that coordinates multiple components.")
