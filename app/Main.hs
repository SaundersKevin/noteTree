{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import qualified Graphics.UI.Threepenny as UI
import Graphics.UI.Threepenny.Core
import qualified CMark as MD
import Data.Text
import qualified Data.Text.IO as DTIO
import System.Environment (getArgs)
import System.Directory (doesFileExist, getCurrentDirectory, listDirectory)
import System.FilePath (takeExtension)

main :: IO ()
main = startGUI defaultConfig { jsPort = Just 8023 } (setup)

setup :: Window -> UI ()
setup window = do

    -- Getting the path after the address using a little JS
    filepath <- callFunction $ ffi "window.location.pathname"

    let path = sanitizePath filepath

    -- find if and what file
    content <- liftIO $ markFromPath path

    -- title
    return window # set title "NoteTree"

    -- body and message. Parses markdown to html
    let htmlContent = MD.commonmarkToHtml [] (content)

    markdownDiv <- UI.div # set UI.html (unpack htmlContent)
    _ <- getBody window #+ [element markdownDiv]
    return ()

-- Helper programs (move to custom header?)
isMarkdown :: FilePath -> Bool
isMarkdown path = let ext = takeExtension path in ext == ".md"

-- Kinda redundant, but I do need to remove the / at the beginning
-- of every filepath
sanitizePath :: FilePath -> FilePath
sanitizePath ('/':path) = sanitizePath path
sanitizePath ('.':path) = sanitizePath path
sanitizePath path = path

markFromPath :: FilePath -> IO Text
markFromPath path = do
 exists <- liftIO $ doesFileExist path
 if exists && (isMarkdown path) then (DTIO.readFile path) else fmap pack (brokenLink)

brokenLink :: IO String
brokenLink = do
  files <- listDirectory "." 
  return $ Prelude.concatMap (\filename -> 
                              if isMarkdown filename
                              then "[" ++ filename ++ "](" ++ filename ++ ")\n"
                              else ""
                             ) files
