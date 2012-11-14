-- | A parser for Verse syntax.
module Language.Verse.Parser (
    Parser,
    runParser,

    document,

    block,
    paragraph,

    inline,
    content,
) where

import Control.Applicative
import Control.Monad.Identity

import Text.Parsec (ParsecT, SourceName, ParseError, runParserT)
import Text.Parsec.Combinator
import Text.Parsec.Char

import Language.Verse.AST

type Parser = ParsecT String () Identity

runParser :: Parser a -> SourceName -> String -> Either ParseError a
runParser p s i = runIdentity $ runParserT p () s i

document :: Parser Document
document = Document <$> manyTill block eof

block :: Parser Block
block = paragraph <* many (void newline)

paragraph :: Parser Block
paragraph = Paragraph . foldr condense [] <$> manyTill inline (void newline <|> eof)
  where
    condense :: Inline -> [Inline] -> [Inline]
    condense (Content c) (Content c' : inlines) = Content (c ++ " " ++ c') : inlines
    condense x xs = x:xs

inline :: Parser Inline
inline = content

content :: Parser Inline
content = Content <$> text

text :: Parser String
text = manyTill (noneOf reservedC) (void newline <|> eof)

reservedC :: String
reservedC = ""
