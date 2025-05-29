//
// CoreData+Extension.swift
// CommonUtils
//
// Created by Dongju Lim on 5/14/25
//
import Foundation
import CoreData

public extension NSPredicate {
    func allKeys() -> [String] {
        var keys: [String] = []
        self.visitExpressions { expression in
            if expression.expressionType == .keyPath {
                let key = expression.keyPath
                keys.append(key)
            }
        }
        return keys
    }

    private func visitExpressions(using block: (NSExpression) -> Void) {
        switch self {
        case let comparisonPredicate as NSComparisonPredicate:
            block(comparisonPredicate.leftExpression)
            block(comparisonPredicate.rightExpression)
        case let compoundPredicate as NSCompoundPredicate:
            compoundPredicate.subpredicates.forEach {
                ($0 as? NSPredicate)?.visitExpressions(using: block)
            }
        default:
            break
        }
    }
}

public extension NSEntityDescription {
    func validKeys() -> Set<String> {
        let attributes = self.attributesByName.keys
        let relationships = self.relationshipsByName.keys
        return Set(attributes).union(relationships)
    }
}
