module Main where

import Language.Haskell.Parser as Parser
import Language.Haskell.Pretty as Pretty

(>>>) = flip (.)

main = interact fIndent

fIndent :: String -> String
fIndent = Parser.parseModule >>> \(ParseOk ast) -> Pretty.prettyPrint ast
