//
//  SimplicialComplex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/17.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct SimplicialComplex: GeometricComplex {
    public let dim: Int
    public let vertexSet: VertexSet
    internal let simplicesList: [[Simplex]]
    
    // root initializer
    public init(_ vertexSet: VertexSet, _ simplices: [[Simplex]]) {
        self.dim = simplices.count - 1
        self.vertexSet = vertexSet
        self.simplicesList = simplices
    }
    
    public init<S: Sequence>(_ vertexSet: VertexSet, _ simplices: S, generate: Bool = false) where S.Iterator.Element == Simplex {
        let simplices = { () -> [[Simplex]] in
            let dim = simplices.reduce(0) { max($0, $1.dim) }
            let set = generate ? simplices.reduce(Set<Simplex>()){$0.union($1.allSubsimplices()) } : Set(simplices)
            
            var simplices: [[Simplex]] = (0 ... dim).map{_ in []}
            for s in set {
                simplices[s.dim].append(s)
            }
            return simplices
        }()
        self.init(vertexSet, simplices)
    }
    
    public func skeleton(_ dim: Int) -> SimplicialComplex {
        let sub = Array(simplicesList[0 ... dim])
        return SimplicialComplex(vertexSet, sub)
    }
    
    public func cells(_ i: Int) -> [Simplex] {
        return simplices(i)
    }
    
    // TODO remove
    public func simplices(_ i: Int) -> [Simplex] {
        return (0...dim).contains(i) ? simplicesList[i] : []
    }
    
    public var facets: [Simplex] { // set of maximal simplices
        var list = Array(simplicesList.reversed().joined())
        var i = 0
        while i < list.count {
            let s = list[i]
            let subs = s.allSubsimplices().dropFirst()
            for t in subs {
                if let j = list.index(of: t) {
                    list.remove(at: j)
                }
            }
            i += 1
        }
        return list
    }
    
    public func boundaryMapMatrix<R: Ring>(_ from: [Simplex], _ to : [Simplex]) -> DynamicMatrix<R> {
        let toIndex = Dictionary(to.enumerated().map{($1, $0)})
        let components = from.enumerated().flatMap{ (j, s) -> [MatrixComponent<R>] in
            return s.faces().enumerated().map { (k, t) -> MatrixComponent<R> in
                let i = toIndex[t]!
                let value: R = (k % 2 == 0) ? 1 : -1
                return (i, j, value)
            }
        }
        
        return DynamicMatrix(rows: to.count, cols: from.count, type: .Sparse, components: components)
    }
}

public extension SimplicialComplex {
    static func point() -> SimplicialComplex {
        return SimplicialComplex.ball(dim: 0)
    }
    
    static func interval() -> SimplicialComplex {
        return SimplicialComplex.ball(dim: 1)
    }
    
    static func circle() -> SimplicialComplex {
        return SimplicialComplex.sphere(dim: 1)
    }
    
    static func ball(dim: Int) -> SimplicialComplex {
        let V = VertexSet(number: dim + 1)
        let s = V.simplex(indices: Array(0...dim))
        return SimplicialComplex(V, [s], generate: true)
    }
    
    static func sphere(dim: Int) -> SimplicialComplex {
        return ball(dim: dim + 1).skeleton(dim)
    }
    
    static func torus(dim: Int) -> SimplicialComplex {
        return (1 ..< dim).reduce(SimplicialComplex.circle()) { (r, _) in r * SimplicialComplex.circle() }
    }
}

// disjoint union
public func +(K1: SimplicialComplex, K2: SimplicialComplex) -> SimplicialComplex {
    let (n1, n2) = (K1.vertexSet.vertices.count, K2.vertexSet.vertices.count)
    let V = VertexSet(number: n1 + n2)
    let dim = max(K1.dim, K2.dim)
    
    let simplices = (0 ... dim).map{ i in
        K1.simplices(i).map{ s in V.simplex(indices: s.vertices.map{$0.index}) } +
            K2.simplices(i).map{ s in V.simplex(indices: s.vertices.map{$0.index + n1}) }
    }
    return SimplicialComplex(V, simplices)
}

// product complex
public func *(K1: SimplicialComplex, K2: SimplicialComplex) -> SimplicialComplex {
    let (n1, n2) = (K1.vertexSet.vertices.count, K2.vertexSet.vertices.count)
    let V = VertexSet(number: n1 * n2)
    
    let (S1, S2) = (K1.facets, K2.facets)
    let simplexPairs: [(Simplex, Simplex)] = S1.flatMap{ s in S2.map{ t in (s, t) } }
    
    let indexPairs: [[(Int, Int)]] = simplexPairs.flatMap{(s, t) -> [[(Int, Int)]] in
        (0 ... s.dim + t.dim).flatMap{ k -> [[(Int, Int)]] in
            // list of ordered indices [(i0 <= i1 <= ... <= ik), ... ]
            let Is: [[Int]] = (s.dim + 1).multichoose(k + 1)
            let Js: [[Int]]  = (t.dim + 1).multichoose(k + 1)
            
            // list of pairs of ordered indices [(I, J), ...]
            let allPairs: [([Int], [Int])]  = Is.flatMap{ I in Js.map{ J in (I, J) } }
            
            // filter valid pairs that form a k-simplex
            let validPairs = allPairs.filter{ (I, J) in
                (0 ..< k).forAll{ (i: Int) -> Bool in
                    (I[i] != I[i + 1]) || (J[i] != J[i + 1])
                }
            }
            
            // indexPairs that correspond to the indices of each VertexSets
            return validPairs.map{ (I, J) -> [(Int, Int)] in
                zip(I, J).map{ (i, j) in (s.vertices[i].index, t.vertices[j].index) }
            }
        }
    }
    
    let simplices = indexPairs.map { (list: [(Int, Int)]) -> Simplex in
        let indices = list.map{ (i, j) in i * n2 + j }
        return V.simplex(indices: indices)
    }.unique()
    
    return SimplicialComplex(V, simplices)
}

public extension SimplicialComplex {
    public func barycentricSubdivision() -> SimplicialComplex {
        var V = VertexSet()
        var S = Set<Simplex>()
        
        func generate(simplices: [Simplex], barycenters: [Vertex]) {
            let s = simplices.last!
            let v = V.barycenterOf(s) ?? {
                let label = (s.dim > 0) ? "b\(s.vertices.map{String($0.index)}.joined())" : s.vertices.first!.label
                return V.add(label: label, barycenterOf: s)
            }()
            
            if s.dim > 0 {
                for t in s.faces() {
                    generate(simplices: simplices + [t], barycenters: barycenters + [v])
                }
            } else {
                let bs = Simplex(barycenters + [v])
                S.insert(bs)
            }
        }
        
        let facets = self.facets
        for s in facets {
            generate(simplices: [s], barycenters: [])
        }
        
        return SimplicialComplex(V, S, generate: true)
    }
}
