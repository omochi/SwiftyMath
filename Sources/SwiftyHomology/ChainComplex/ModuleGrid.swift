//
//  GradedModuleStructure.swift
//  Sample
//
//  Created by Taketo Sano on 2018/05/18.
//

import Foundation
import SwiftyMath

public typealias ModuleSequence<A: BasisElementType, R: EuclideanRing> = ModuleGrid<_1, A, R>
public typealias ModuleGrid2<A: BasisElementType, R: EuclideanRing> = ModuleGrid<_2, A, R>

public struct ModuleGrid<Dim: _Int, A: BasisElementType, R: EuclideanRing>: CustomStringConvertible {
    public typealias Object = SimpleModuleStructure<A, R>
    
    public let name: String
    internal var grid: [IntList : Object?]
    
    public init(name: String? = nil, grid: [IntList : Object?]) {
        self.name = name ?? ""
        self.grid = grid.exclude{ $0.value?.isTrivial ?? false }
    }
    
    public init<S: Sequence>(name: String? = nil, list: S) where S.Element == (IntList, Object?) {
        self.init(name: name, grid: Dictionary(pairs: list))
    }
    
    public init<S: Sequence>(name: String? = nil, list: S) where S.Element == (IntList, [A]?) {
        self.init(name: name, grid: Dictionary(pairs: list.map{ (I, basis) in
            (I, basis.map{ Object(generators: $0) })
        }))
    }
    
    public subscript(I: IntList) -> Object? {
        get {
            return grid[I] ?? .zeroModule
        } set {
            grid[I] = newValue
        }
    }
    
    public var gradingDim: Int {
        return Dim.intValue
    }
    
    public var nonZeroMultiDegrees: [IntList] {
        return grid.keys.sorted()
    }
    
    public var isTrivial: Bool {
        return nonZeroMultiDegrees.isEmpty
    }
    
    public var isDetermined: Bool {
        return grid.values.forAll{ $0 != nil }
    }
    
    public var freePart: ModuleGrid<Dim, A, R> {
        return ModuleGrid(name: "\(name)_free", grid: grid.mapValues{ $0?.freePart })
    }
    
    public var torsionPart: ModuleGrid<Dim, A, R> {
        return ModuleGrid(name: "\(name)_tor", grid: grid.mapValues{ $0?.torsionPart })
    }

    public func shifted(_ I: IntList) -> ModuleGrid<Dim, A, R> {
        return ModuleGrid(name: name, grid: grid.mapKeys{ $0 + I} )
    }
    
    public func asChainComplex(degree: IntList, differential d: @escaping (IntList, A) -> FreeModule<A, R>) -> MChainComplex<Dim, A, R> {
        return asChainComplex(differential: MChainMap(degree: degree, func: d))
    }
    
    public func asChainComplex(differential d: MChainMap<Dim, A, A, R>) -> MChainComplex<Dim, A, R> {
        return MChainComplex(base: self, differential: d)
    }
    
    public func homology(name: String? = nil, degree: IntList, differential d: @escaping (IntList, A) -> FreeModule<A, R>) -> ModuleGrid<Dim, A, R> {
        return asChainComplex(degree: degree, differential: d).homology(name: name)
    }
    
    public func describe(_ I: IntList) {
        if let o = self[I] {
            print("\(I)", terminator: " ")
            o.describe()
        } else {
            print("\(I) ?")
        }
    }
    
    public func describeAll() {
        for I in nonZeroMultiDegrees {
            describe(I)
        }
    }
    
    public var description: String {
        return "\(name) {\n\( nonZeroMultiDegrees.map{ I in "\t\(I) " + (self[I]?.description ?? "?") }.joined(separator: ",\n"))\n}"
    }
}

public extension ModuleGrid where Dim == _1 {
    public init<S: Sequence>(name: String? = nil, list: S) where S.Element == [A]? {
        self.init(name: name, list: list.enumerated().map{ (i, b) in (i, b)})
    }
    
    public init<S: Sequence>(name: String? = nil, list: S) where S.Element == (Int, [A]?) {
        self.init(name: name, list: list.map{ (i, basis) in (IntList(i), basis) })
    }
    
    public init<S: Sequence>(name: String? = nil, list: S) where S.Element == (Int, Object?) {
        self.init(name: name, list: list.map{ (i, o) in (IntList(i), o) })
    }
    
    public subscript(i: Int) -> Object? {
        get {
            return self[IntList(i)]
        } set {
            self[IntList(i)] = newValue
        }
    }
    
    public var nonZeroDegrees: [Int] {
        return nonZeroMultiDegrees.map{ I in I[0] }
    }
    
    public var bottomDegree: Int {
        return nonZeroDegrees.min() ?? 0
    }
    
    public var topDegree: Int {
        return nonZeroDegrees.max() ?? 0
    }
    
    public func bettiNumer(_ i: Int) -> Int? {
        return self[i]?.rank
    }
    
    public var eulerCharacteristic: Int {
        return nonZeroDegrees.sum{ i in (-1).pow(i) * bettiNumer(i)! }
    }
    
    public func shifted(_ i: Int) -> ModuleSequence<A, R> {
        return shifted(IntList(i))
    }
    
    public func asChainComplex(degree: Int, differential d: @escaping (Int, A) -> FreeModule<A, R>) -> ChainComplex<A, R> {
        return asChainComplex(degree: IntList(degree), differential: {(I, a) in d(I[0], a)})
    }
    
    public func homology(name: String? = nil, degree: Int, differential d: @escaping (Int, A) -> FreeModule<A, R>) -> ModuleGrid<Dim, A, R> {
        return asChainComplex(degree: degree, differential: d).homology(name: name)
    }
    
    public func describe(_ i: Int) {
        describe(IntList(i))
    }
}

public extension ModuleGrid where Dim == _2 {
    public init<S: Sequence>(name: String? = nil, list: S) where S.Element == (Int, Int, [A]?) {
        self.init(name: name, list: list.map{ (i, j, basis) in (IntList(i, j), basis) })
    }
    
    public init<S: Sequence>(name: String? = nil, list: S) where S.Element == (Int, Int, Object?) {
        self.init(name: name, list: list.map{ (i, j, o) in (IntList(i, j), o) })
    }
    
    public subscript(i: Int, j: Int) -> Object? {
        get {
            return self[IntList(i, j)]
        } set {
            self[IntList(i, j)] = newValue
        }
    }
    
    public var nonZeroDegrees: [(Int, Int)] {
        return nonZeroMultiDegrees.map{ I in (I[0], I[1]) }
    }
    
    public func shifted(_ i: Int, _ j: Int) -> ModuleGrid2<A, R> {
        return shifted(IntList(i, j))
    }
    
    public func asChainComplex(degree: (Int, Int), differential d: @escaping (Int, Int, A) -> FreeModule<A, R>) -> ChainComplex2<A, R> {
        return asChainComplex(degree: IntList(degree.0, degree.1), differential: {(I, a) in d(I[0], I[1], a)})
    }
    
    public func homology(name: String? = nil, degree: (Int, Int), differential d: @escaping (Int, Int, A) -> FreeModule<A, R>) -> ModuleGrid<Dim, A, R> {
        return asChainComplex(degree: degree, differential: d).homology(name: name)
    }

    public func describe(_ i: Int, _ j: Int) {
        describe(IntList(i, j))
    }
    
    public func printTable() {
        if grid.isEmpty {
            return
        }
        
        let keys = grid.keys
        let (iList, jList) = ( keys.map{$0[0]}.unique(), keys.map{$0[1]}.unique() )
        let (i0, i1) = (iList.min()!, iList.max()!)
        let (j0, j1) = (jList.min()!, jList.max()!)
        
        let jEvenOnly = jList.forAll{ j in (j - j0).isEven }
        
        let colList = (i0 ... i1).toArray()
        let rowList = (j0 ... j1).reversed().filter{ j in jEvenOnly ? (j - j0).isEven : true }.toArray()

        let table = Format.table("j\\i", rows: rowList, cols: colList) { (j, i) -> String in
            if let o = self[i, j] {
                return !o.isTrivial ? o.description : ""
            } else {
                return "?"
            }
        }
        
        print(table)
    }
}

public extension ModuleGrid where R == 𝐙 {
    public var structureCode: String {
        return nonZeroMultiDegrees.map{ I in
            if let s = self[I] {
                return "\(I): \(s.structureCode)"
            } else {
                return "\(I): ?"
            }
        }.joined(separator: ", ")
    }
    
    public func orderNtorsionPart<n: _Int>(_ type: n.Type) -> ModuleGrid<Dim, A, IntegerQuotientRing<n>> {
        return ModuleGrid<Dim, A, IntegerQuotientRing<n>>(
            name: "\(name)_\(n.intValue)",
            grid: grid.mapValues{ $0?.orderNtorsionPart(type) }
        )
    }
    
    public var order2torsionPart: ModuleGrid<Dim, A, 𝐙₂> {
        return orderNtorsionPart(_2.self)
    }
}
