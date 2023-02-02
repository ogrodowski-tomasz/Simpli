//
//  UIColorTransformer.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import Foundation
import UIKit

class UIColorTransformer: ValueTransformer {

    override func transformedValue(_ value: Any?) -> Any? {
        // Converting UIColor to Data
        guard let color = value as? UIColor else { return nil }

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch  {
            print("DEBUG: Failed to convert UIColor to Data: \(error)")
            return nil
        }
    }


    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
            return color
        } catch  {
            print("DEBUG: Failed to convert Data to UIColor: \(error)")
            return nil
        }
    }

}
