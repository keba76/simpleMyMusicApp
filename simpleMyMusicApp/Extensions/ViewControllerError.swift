//
//  ViewControllerError.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension NSError {
    static func createError(_ code: Int, description: String) -> NSError {
        return NSError(domain: "com.firebase", code: 400, userInfo: [ "NSLocalizedDescription" : description ])
    }
}
