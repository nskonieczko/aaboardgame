//
//  File.swift
//  
//
//  Created by Nick Konieczko on 7/7/24.
//

import Foundation
/*
public func handleMovement(player: Player, from: Territory, to: Territory, units: [any Unit]) {
    // Validate the movement
    
    // Move units
    for unit in units {
        from.removeUnit(unit: unit)
        to.addUnit(unit: unit)
    }
    
    /*
     
     
     */
    print("\(units.count) units moved from \(from.name) to \(to.name)")
}

func handleCombat(attacker: Player, defender: Player, attackingUnits: [any Unit], defendingUnits: [any Unit]) -> [any Unit] {
    
    /*
     """
     Simulates combat between two players, considering unit types, stacking, terrain, dice rolls, and various combat rules.
     
     Args:
     attacker (Player): The attacking player.
     defender (Player): The defending player.
     attackingUnits: List of units selected by attacker for combat.
     defendingUnits: List of units selected by defender for combat (optional).
     
     Returns:
     [Unit]: List of surviving units from both sides after combat.
     """
     
     var survivingAttackers = attackingUnits
     var survivingDefenders = defendingUnits.isEmpty ? Array(defender.controlledTerritories.first!.units) : defendingUnits  // Use provided defenders if any, otherwise use all units in territory
     
     // Check for combined arms bonus (more complex logic for specific unit combinations)
     let hasCombinedArmsBonus = attackingUnits.contains { $0.type == .infantry } && attackingUnits.contains { $0.type == .tank }
     let combinedArmsModifier = hasCombinedArmsModifier ? -1 : 0
     
     // Loop through attacking units
     for attackerUnit in attackingUnits {
     var attackRollNeeded = defender.getDefenseValue(attacker: attackerUnit.type, terrain: defender.controlledTerritories.first!.terrain) - combinedArmsModifier
     
     // Apply terrain modifiers (placeholder, can be expanded for different terrains)
     if defender.controlledTerritories.first!.terrain == .mountains && attackerUnit.type.isLandUnit {
     attackRollNeeded += 1  // Penalty for attacking into mountains
     }
     
     let attackRoll = Int.random(in: 1...6)
     
     var didAttackHit = attackRoll <= attackRollNeeded
     
     // Check for AA defense against air units
     if attackerUnit.type.isLandUnit && defender.controlledTerritories.first!.units.contains(where: { $0.type == .aaGun }) {
     let aaRoll = Int.random(in: 1...6)
     didAttackHit = attackRoll <= attackRollNeeded && aaRoll > defender.getDefenseValue(attacker: .aaGun, terrain: defender.controlledTerritories.first!.terrain)
     }
     
     // Resolve attack
     if didAttackHit {
     survivingDefenders = survivingDefenders.filter { $0.takeDamage(damage: attackerUnit.type.attackValue) }
     }
     }
     
     // Handle defender counter-attacks (optional, some units can't counter)
     survivingDefenders = survivingDefenders.filter { canCounterAttack(unit: $0, attackers: attackingUnits) }
     for defenderUnit in survivingDefenders {
     let counterAttackRoll = Int.random(in: 1...6)
     let didCounterAttackHit = counterAttackRoll <= defenderUnit.type.defenseValue
     
     // Check for special cases (e.g., submarines vs. destroyers)
     if defenderUnit.type == .submarine && attackingUnits.contains(where: { $0.type == .destroyer }) {
     didCounterAttackHit = true  // Destroyers have depth charge attack that ignores defense
     }
     
     if didCounterAttackHit {
     let randomAttacker = attackingUnits.randomElement()!  // Randomly select an attacker to counter
     randomAttacker.takeDamage(damage: 1)  // Basic counter-attack damage
     print(f"{defenderUnit.type.rawValue} counter-attacks {randomAttacker.type.rawValue}!")
     }
     }
     
     // Remove destroyed units
     survivingAttackers = survivingAttackers.filter { $0.health > 0 }
     survivingDefenders = survivingDefenders.filter { $0.health > 0 }
     
     // Print combat log
     printCombatLog(attackers: attackingUnits, defenders: defendingUnits.isEmpty ? defender.controlledTerritories.first!.units : defendingUnits, survivingAttackers: survivingAttackers, survivingDefenders: survivingDefenders)
     
     return survivingAttackers + survivingDefenders
     }
     
     public func handleCombat(attacker: Player, defender: Player, territory: Territory) {
     // Update controlled territories based on surviving units
     let attackerTerritory = attacker.controlledTerritories.first!  // Assuming player has at least one territory
     let defenderTerritory = defender.controlledTerritories.first!  // Assuming player has at least one territory
     
     attacker.controlledTerritories = survivingAttackers.isEmpty ? [] : [attackerTerritory]  // Update if attacker loses all units
     defender.controlledTerritories = survivingDefenders.isEmpty ? [] : [defenderTerritory]  // Update if defender loses all units
     
     var survivingAttackers: [Unit] = []
     var survivingDefenders: [Unit] = Array(defender.units)
     
     // Check for combined arms bonus (more complex logic for specific unit combinations)
     let hasCombinedArmsBonus = attacker.units.contains { $0.type == .infantry } && attacker.units.contains { $0.type == .tank }
     let combinedArmsModifier = hasCombinedArmsBonus ? -1 : 0
     
     // Loop through attacking units
     for attackerUnit in attacker.units {
     var attackRollNeeded = defender.getDefenseValue(attacker: attackerUnit.type, terrain: defender.terrain) - combinedArmsModifier
     
     // Apply terrain modifiers (placeholder, can be expanded for different terrains)
     if defender.terrain == .mountains && attackerUnit.type.isLandUnit {
     attackRollNeeded += 1  // Penalty for attacking into mountains
     }
     
     let attackRoll = Int.random(in: 1...6)
     
     var didAttackHit = attackRoll <= attackRollNeeded
     
     // Check for AA defense against air units
     if attackerUnit.type.isLandUnit && defender.units.contains(where: { $0.type == .aaGun }) {
     let aaRoll = Int.random(in: 1...6)
     didAttackHit = attackRoll <= attackRollNeeded && aaRoll > defender.getDefenseValue(attacker: .aaGun, terrain: defender.terrain)
     }
     
     // Resolve attack
     if didAttackHit {
     survivingDefenders = survivingDefenders.filter { $0.takeDamage(damage: attackerUnit.type.attackValue) }
     }
     
     survivingAttackers.append(attackerUnit)
     }
     
     // Handle defender counter-attacks (optional, some units can't counter)
     survivingDefenders = survivingDefenders.filter { canCounterAttack(unit: $0, attackers: attacker.units) }
     for defenderUnit in survivingDefenders {
     let counterAttackRoll = Int.random(in: 1...6)
     let didCounterAttackHit = counterAttackRoll <= defenderUnit.type.defenseValue
     
     // Check for special cases (e.g., submarines vs. destroyers)
     if defenderUnit.type == .submarine && attacker.units.contains(where: { $0.type == .destroyer }) {
     didCounterAttackHit = true  // Destroyers have depth charge attack that ignores defense
     }
     
     if didCounterAttackHit {
     let randomAttacker = attacker.units.randomElement()!  // Randomly select an attacker to counter
     randomAttacker.takeDamage(damage: 1)  // Basic counter-attack damage
     print(f"{defenderUnit.type.rawValue} counter-attacks {randomAttacker.type.rawValue}!")
     }
     }
     
     // Remove destroyed units
     survivingAttackers = survivingAttackers.filter { $0.health > 0 }
     survivingDefenders = survivingDefenders.filter { $0.health > 0 }
     
     // Print combat log
     printCombatLog(attackers: attacker.units, defenders: defender.units, survivingAttackers: survivingAttackers, survivingDefenders: survivingDefenders)
     
     return survivingAttackers + survivingDefenders
     }
     
     public func rollDice(numberOfDice: Int) -> [Int] {
     var rolls = [Int]()
     for _ in 0..<numberOfDice {
     rolls.append(Int.random(in: 1...6))
     }
     return rolls
     }
     
     public func calculateHits(rolls: [Int]) -> Int {
     return rolls.filter { $0 <= 3 }.count  // Assume a hit is a roll of 3 or less
     }
     
     public func applyHits(units: inout Set<Unit>, hits: Int) {
     for _ in 0..<hits {
     if let unit = units.first {
     units.remove(unit)
     }
     }
     }
     */
    return []
}
*/
