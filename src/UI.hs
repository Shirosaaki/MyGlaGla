{-
-- UI helpers for printing errors with styling and optional HTML report
-}
module UI (printError) where

import System.IO (hPutStrLn, stderr)
import System.Directory (canonicalizePath)
import System.IO (IOMode(AppendMode, WriteMode), withFile, hPutStr)
import System.Process (callCommand)
import Control.Exception (try, SomeException)
import System.IO.Unsafe (unsafePerformIO)
import Data.IORef
import Config

{-# NOINLINE htmlInitializedRef #-}
htmlInitializedRef :: IORef Bool
htmlInitializedRef = unsafePerformIO (newIORef False)

{-# NOINLINE htmlBrowserOpenedRef #-}
htmlBrowserOpenedRef :: IORef Bool
htmlBrowserOpenedRef = unsafePerformIO (newIORef False)

-- Public API
printError :: String -> IO ()
printError msg = do
  cfg <- getConfig
  case cfgMode cfg of
    Console -> printConsole (cfgErrorStyle cfg) msg
    Html    -> do
      printConsole (cfgErrorStyle cfg) msg
      ensureHtmlSession (cfgHtml cfg)
      appendHtml (cfgHtml cfg) (cfgErrorStyle cfg) msg

-- Console output using ANSI styling
printConsole :: ErrorStyle -> String -> IO ()
printConsole style msg = do
  let prefix = esPrefix style
      styled = ansiStart style ++ prefix ++ msg ++ ansiReset
  hPutStrLn stderr styled

-- We intentionally emit truecolor ANSI escapes ourselves instead of relying on the
-- 16-color palette, because VS Code terminals often remap named ANSI colors.
ansiStart :: ErrorStyle -> String
ansiStart es =
  maybe "" (ansiColor . lower) (esColor es) ++
  (if esBold es then "\ESC[1m" else "") ++
  (if esUnderline es then "\ESC[4m" else "")

ansiReset :: String
ansiReset = "\ESC[0m"

ansiColor :: String -> String
ansiColor s =
  case parseHexColor s of
    Just (r,g,b) -> ansiRgb r g b
    Nothing -> case s of
      "black"   -> ansiRgb 0 0 0
      "red"     -> ansiRgb 255 0 0
      "green"   -> ansiRgb 0 255 0
      "yellow"  -> ansiRgb 255 255 0
      "blue"    -> ansiRgb 0 128 255
      "magenta" -> ansiRgb 255 0 255
      "cyan"    -> ansiRgb 0 255 255
      "white"   -> ansiRgb 255 255 255
      _          -> ""

ansiRgb :: Int -> Int -> Int -> String
ansiRgb r g b = "\ESC[38;2;" ++ show (clamp r) ++ ";" ++ show (clamp g) ++ ";" ++ show (clamp b) ++ "m"

clamp :: Int -> Int
clamp x | x < 0 = 0
        | x > 255 = 255
        | otherwise = x

parseHexColor :: String -> Maybe (Int, Int, Int)
parseHexColor ('#':a:b:c:d:e:f:[]) = do
  r <- hex2 a b
  g <- hex2 c d
  bl <- hex2 e f
  pure (r,g,bl)
parseHexColor _ = Nothing

hex2 :: Char -> Char -> Maybe Int
hex2 a b = do
  hi <- hex1 a
  lo <- hex1 b
  pure (hi * 16 + lo)

hex1 :: Char -> Maybe Int
hex1 c
  | '0' <= c && c <= '9' = Just (fromEnum c - fromEnum '0')
  | 'a' <= c && c <= 'f' = Just (10 + fromEnum c - fromEnum 'a')
  | 'A' <= c && c <= 'F' = Just (10 + fromEnum c - fromEnum 'A')
  | otherwise = Nothing

lower :: String -> String
lower = map toLower'

toLower' :: Char -> Char
toLower' c | 'A' <= c && c <= 'Z' = toEnum (fromEnum c + 32)
           | otherwise = c

-- Append an HTML snippet for the error message
appendHtml :: HtmlStyle -> ErrorStyle -> String -> IO ()
appendHtml htmlS style msg = do
  let path = hsPath htmlS
  withFile path AppendMode $ \h -> do
    let color = maybe (hsColor htmlS) id (esColor style)
    hPutStr h (htmlEntry (hsFontFamily htmlS) (hsFontSize htmlS) color (esPrefix style) msg)

writeHeader :: FilePath -> IO ()
writeHeader path = withFile path WriteMode $ \h -> do
  hPutStr h "<!doctype html><html><head><meta charset=\"utf-8\"><title>glados errors</title>"
  hPutStr h "<style>body{background:#111;color:#ddd;font-family:sans-serif;padding:16px}"
  hPutStr h ".err{margin:8px 0;padding:8px 12px;border-left:4px solid #ff5555;background:#1b1b1b;border-radius:4px;white-space:pre-wrap}"
  hPutStr h "</style></head><body>\n"

-- In HTML mode, reset the report once per process run and open it once.
ensureHtmlSession :: HtmlStyle -> IO ()
ensureHtmlSession htmlS = do
  inited <- readIORef htmlInitializedRef
  if inited
    then pure ()
    else do
      writeHeader (hsPath htmlS)  -- WriteMode truncates: clears past runs
      writeIORef htmlInitializedRef True
      opened <- readIORef htmlBrowserOpenedRef
      if opened
        then pure ()
        else do
          absPath <- canonicalizePath (hsPath htmlS)
          -- Best-effort: open in default browser on Linux (ignore failures)
          _ <- (try (callCommand ("xdg-open \"" ++ absPath ++ "\" >/dev/null 2>&1")) :: IO (Either SomeException ()))
          writeIORef htmlBrowserOpenedRef True

htmlEntry :: String -> String -> String -> String -> String -> String
htmlEntry family size color prefix msg =
  "<div class=\"err\" style=\"font-family:" ++ esc family ++ ";font-size:" ++ esc size ++ ";border-color:" ++ esc color ++ ";\">" ++
  "<strong>" ++ esc prefix ++ "</strong> " ++ esc msg ++ "</div>\n"

esc :: String -> String
esc = concatMap repl
  where
    repl '<' = "&lt;"
    repl '>' = "&gt;"
    repl '&' = "&amp;"
    repl '"' = "&quot;"
    repl '\'' = "&#39;"
    repl c = [c]
