//
//  Utilities.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 6/29/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Random Utilities
struct RandomUtilities {

    static var shared = RandomUtilities()

    fileprivate class CacheArray: NSObject {
        var array: [String] = []
        // 缓存已经分配过了的索引
        var cachedRandomedNamed: [Int] = []

        init(array: [String]) {
            self.array = array
            super.init()
        }
    }

    fileprivate var cachedArrayDict: [String: CacheArray] = [:]

    mutating func append(_ randomArray: [String]) -> String {
        let key = randomKey()
        let value = CacheArray(array: randomArray)
        cachedArrayDict.updateValue(value, forKey: key)
        return key
    }

    // 这个随机数的生成方法不合理、不科学，暂时用一下！~~~~(>_<)~~~~
    fileprivate var increaseNumberForRandom: Double = 0
    fileprivate mutating func randomKey() -> String {
        increaseNumberForRandom += 123456789
        return (CFAbsoluteTimeGetCurrent() + increaseNumberForRandom).description
    }

    // 随机分配值
    mutating func randomValue(with key: String) -> String? {
        guard let cacheArray = cachedArrayDict[key] else { return nil }
        let num = cacheArray.array.count
        guard num > 0 else { return nil }

        var index = 0
        repeat {
            index = min(max(0, Int(arc4random_uniform(UInt32(num)))), num - 1)
        } while cacheArray.cachedRandomedNamed.contains(index)
        cacheArray.cachedRandomedNamed.append(index)
        // 全部使用一遍了
        if cacheArray.cachedRandomedNamed.count >= num {
            cacheArray.cachedRandomedNamed.removeAll()
        }
        return cacheArray.array[index]
    }
}

// MARK: - delay task
func delay(_ delta: Double, callFunc: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delta * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            callFunc()
    }
}

func async<T, N>(_ delta: Double, param: T, task: @escaping (_ value: T) -> N, callFunc: @escaping (_ result: N) -> ()) {
    func doTaskThenCallback() {
        let t = task(param)
        DispatchQueue.main.async(execute: {
            callFunc(t)
        })
    }

    if delta > 0.0 {
        DispatchQueue.global().asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delta * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            doTaskThenCallback()
        }
    } else {
        DispatchQueue.global().async {
            doTaskThenCallback()
        }
    }
}

// MARK: - extension UIDeviceOrientation/UIInterfaceOrientation for debug print/utilities.
extension UIDeviceOrientation: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .faceDown: return "[UIDeviceOrientation] : faceDown"
        case .faceUp: return "[UIDeviceOrientation] : faceUp"
        case .landscapeLeft: return "[UIDeviceOrientation] : landscapeLeft"
        case .landscapeRight: return "[UIDeviceOrientation] : landscapeRight"
        case .portrait: return "[UIDeviceOrientation] : portrait"
        case .portraitUpsideDown: return "[UIDeviceOrientation] : portraitUpsideDown"
        case .unknown: return "[UIDeviceOrientation] : unknown"
        }
    }
}

extension UIDeviceOrientation: CustomStringConvertible {
    public var description: String { return debugDescription }
}

extension UIInterfaceOrientation: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .landscapeLeft: return "[UIInterfaceOrientation] : landscapeLeft"
        case .landscapeRight: return "[UIInterfaceOrientation] : landscapeRight"
        case .portrait: return "[UIInterfaceOrientation] : portrait"
        case .portraitUpsideDown: return "[UIInterfaceOrientation] : portraitUpsideDown"
        case .unknown: return "[UIInterfaceOrientation] : unknown"
        }
    }
}

extension UIInterfaceOrientation: CustomStringConvertible {
    public var description: String { return debugDescription }
}

extension UIInterfaceOrientationMask {

    var isLandscape: Bool {
        return contains(UIInterfaceOrientationMask.landscape)
    }

    var isPortrait: Bool {
        return contains(UIInterfaceOrientationMask.portrait) || contains(UIInterfaceOrientationMask.portraitUpsideDown)
    }
}
