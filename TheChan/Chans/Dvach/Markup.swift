//
//  Markup.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 25.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import Kanna

class DvachMarkup {
    
    private struct Node {
        let offset: Int
        let name: String
        let innerText: String
        let rawNode: XMLElement
        
        init(name: String, offset: Int, innerText: String, rawNode: XMLElement) {
            self.offset = offset
            self.name = name
            self.innerText = innerText
            self.rawNode = rawNode
        }
        
        subscript(attribute: String) -> String? {
            get {
                return rawNode[attribute]
            }
        }
    }
    
    
    var fontSize = CGFloat(15)
    var smallFontSize = CGFloat(11)
    let html: String
    private let document: HTMLDocument
    
    init?(from html: String) {
        self.html = html.replacingOccurrences(of: "<br>", with: "\n")
        guard let document = HTML(html: self.html, encoding: .utf8) else { return nil }
        self.document = document
    }
    
    private func walk(callback: (Node) -> Void) {
        var textOffset = 0
        guard let body = document.body else { return }
        for node in body.xpath("/*//.") {
            let nodeName = node.tagName ?? ""
            let nodeText = node.text ?? ""
            
            if nodeName == "text" {
                textOffset += nodeText.characters.count
                continue
            }
            
            let resultNode = Node(name: nodeName, offset: textOffset, innerText: nodeText, rawNode: node)
            callback(resultNode)
        }
    }
    
    private func getAttributesFrom(node: Node) -> [String: Any]? {
        if node.name == "strong" {
            return [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)]
        }
        
        if node.name == "em" {
            return [NSFontAttributeName: UIFont.italicSystemFont(ofSize: fontSize)]
        }
        
        let nodeClass = node["class"]
        
        if nodeClass == "spoiler" {
            return [
                NSBackgroundColorAttributeName: UIColor.lightGray,
                NSForegroundColorAttributeName: UIColor.black
            ]
        }
        
        if nodeClass == "unkfunc" {
            return [NSForegroundColorAttributeName: UIColor(red: 76 / 255.0, green: 217 /  255.0, blue: 100 / 255.0, alpha: 1.0)]
        }
        
        if node.name == "sub" {
            return [
                NSBaselineOffsetAttributeName: CGFloat(-2),
                NSFontAttributeName: UIFont.systemFont(ofSize: smallFontSize)
            ]
        }
        
        if node.name == "sup" {
            return [
                NSBaselineOffsetAttributeName: CGFloat(5),
                NSFontAttributeName: UIFont.systemFont(ofSize: smallFontSize)
            ]
        }
        
        if node.name == "a" {
            return [
                NSLinkAttributeName: "link",
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue
            ]
        }
        
        return nil
    }
    
    private func render(nodes: [Node], to attributedString: NSMutableAttributedString) {
        for node in nodes {
            let attributes = getAttributesFrom(node: node)
            if attributes == nil {
                continue
            }
            
            let length = node.innerText.characters.count
            attributedString.addAttributes(attributes!, range: NSRange(location: node.offset, length: length))
        }
    }
    
    func getAttributedString() -> NSAttributedString {
        var fullText = ""
        var nodes = [Node]()
        walk { node in
            if node.name == "body" {
                fullText = node.innerText
            } else if node.name != "html" {
                nodes.append(node)
            }
        }
        
        let resultAttributedString = NSMutableAttributedString(string: fullText, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.white
            ])
        
        render(nodes: nodes, to: resultAttributedString)
        return resultAttributedString
    }
}
