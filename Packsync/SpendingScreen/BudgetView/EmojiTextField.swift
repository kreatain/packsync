//
//  EmojiTextField.swift
//  Packsync
//
//  Created by Leo Yang  on 11/15/24.
//


import UIKit

class EmojiTextField: UITextField {
    // Required for iOS 13+
    override var textInputContextIdentifier: String? {
        return "" // Return a non-nil value to enable the Emoji keyboard
    }

    override var textInputMode: UITextInputMode? {
        // Return the Emoji input mode if available
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}