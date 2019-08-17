//
//  Block.swift
//  MarkdownKit
//
//  Created by Matthias Zenger on 25/04/2019.
//  Copyright © 2019 Google LLC.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

///
/// Enumeration of Markdown blocks. This enumeration defines the block structure,
/// i.e. the abstract syntax, of Markdown supported by MarkdownKit. The structure of
/// inline text is defined by the `Text` struct.
/// 
public enum Block: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
  case document(Blocks)
  case blockquote(Blocks)
  case list(Int?, Bool, Blocks)
  case listItem(ListType, Bool, Blocks)
  case paragraph(Text)
  case heading(Int, Text)
  case indentedCode(Lines)
  case fencedCode(String?, Lines)
  case htmlBlock(Lines)
  case referenceDef(String, Substring, Lines)
  case thematicBreak

  /// Returns a description of the block as a string.
  public var description: String {
    switch self {
      case .document(let blocks):
        return "document(\(self.string(from: blocks))))"
      case .blockquote(let blocks):
        return "blockquote(\(self.string(from: blocks))))"
      case .list(let start, let tight, let blocks):
        if let start = start {
          return "list(\(start), \(tight ? "tight" : "loose"), \(self.string(from: blocks)))"
        } else {
          return "list(\(tight ? "tight" : "loose"), \(self.string(from: blocks)))"
        }
      case .listItem(let type, let tight, let blocks):
        return "listItem(\(type), \(tight ? "tight" : "loose"), \(self.string(from: blocks)))"
      case .paragraph(let text):
        return "paragraph(\(text.debugDescription))"
      case .heading(let level, let text):
        return "heading(\(level), \(text.debugDescription))"
      case .indentedCode(let lines):
        if let firstLine = lines.first {
          var code = firstLine.debugDescription
          for i in 1..<lines.count {
            code = code + ", \(lines[i].debugDescription)"
          }
          return "indentedCode(\(code))"
        } else {
          return "indentedCode()"
        }
      case .fencedCode(let info, let lines):
        if let firstLine = lines.first {
          var code = firstLine.debugDescription
          for i in 1..<lines.count {
            code = code + ", \(lines[i].debugDescription)"
          }
          if let info = info {
            return "fencedCode(\(info), \(code))"
          } else {
            return "fencedCode(\(code))"
          }
        } else {
          if let info = info {
            return "fencedCode(\(info),)"
          } else {
            return "fencedCode()"
          }
        }
      case .htmlBlock(let lines):
        if let firstLine = lines.first {
          var code = firstLine.debugDescription
          for i in 1..<lines.count {
            code = code + ", \(lines[i].debugDescription)"
          }
          return "htmlBlock(\(code))"
        } else {
          return "htmlBlock()"
        }
      case .referenceDef(let label, let dest, let title):
        if let firstLine = title.first {
          var titleStr = firstLine.debugDescription
          for i in 1..<title.count {
            titleStr = titleStr + ", \(title[i].debugDescription)"
          }
          return "referenceDef(\(label), \(dest), \(titleStr))"
        } else {
          return "referenceDef(\(label), \(dest))"
        }
      case .thematicBreak:
        return "thematicBreak"
    }
  }

  /// Returns a debug description.
  public var debugDescription: String {
    return self.description
  }

  private func string(from blocks: Blocks) -> String {
    var res = ""
    for block in blocks {
      if res.isEmpty {
        res = block.description
      } else {
        res = res + ", " + block.description
      }
    }
    return res
  }

  /// Defines an equality relation for two blocks.
  public static func == (lhs: Block, rhs: Block) -> Bool {
    switch (lhs, rhs) {
      case (.document(let lblocks), .document(let rblocks)):
        return lblocks == rblocks
      case (.blockquote(let lblocks), .blockquote(let rblocks)):
        return lblocks == rblocks
      case (.list(let ltype, let lt, let lblocks), .list(let rtype, let rt, let rblocks)):
        return ltype == rtype && lt == rt && lblocks == rblocks
      case (.listItem(let ltype, let lt, let lblocks), .listItem(let rtype, let rt, let rblocks)):
        return ltype == rtype && lt == rt && lblocks == rblocks
      case (.paragraph(let lstrs), .paragraph(let rstrs)):
        return lstrs == rstrs
      case (.heading(let ln, let lheadings), .heading(let rn, let rheadings)):
        return ln == rn && lheadings == rheadings
      case (.indentedCode(let lcode), .indentedCode(let rcode)):
        return lcode == rcode
      case (.fencedCode(let linfo, let lcode), .fencedCode(let rinfo, let rcode)):
        return linfo == rinfo && lcode == rcode
      case (.htmlBlock(let llines), .htmlBlock(let rlines)):
        return llines == rlines
      case (.referenceDef(let llab, let ldest, let lt), .referenceDef(let rlab, let rdest, let rt)):
        return llab == rlab && ldest == rdest && lt == rt
      case (.thematicBreak, .thematicBreak):
        return true
      default:
        return false
    }
  }
}

///
/// Enumeration of Markdown list types.
/// 
public enum ListType: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
  case bullet(Character)
  case ordered(Int, Character)

  public var startNumber: Int? {
    switch self {
      case .bullet(_):
        return nil
      case .ordered(let start, _):
        return start
    }
  }

  public func compatible(with other: ListType) -> Bool {
    switch (self, other) {
      case (.bullet(let lc), .bullet(let rc)):
        return lc == rc
      case (.ordered(_, let lc), .ordered(_, let rc)):
        return lc == rc
      default:
        return false
    }
  }

  public var description: String {
    switch self {
      case .bullet(let char):
        return "bullet(\(char.description))"
      case .ordered(let num, let delimiter):
        return "ordered(\(num), \(delimiter))"
    }
  }

  public var debugDescription: String {
    return self.description
  }
}