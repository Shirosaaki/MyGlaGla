{-# LANGUAGE OverloadedStrings #-}
{-
-- Configuration loading for UI/formatting
-}
module Config (
  Config(..),
  ErrorStyle(..),
  HtmlStyle(..),
  OutputMode(..),
  getConfig
) where

import System.Environment (lookupEnv)
import System.Directory (doesFileExist, getHomeDirectory)
import System.FilePath ((</>))
import Data.Maybe()
import qualified Data.Yaml as Y
import Data.Yaml ((.:?), (.!=))
import Data.Aeson (FromJSON(..), withObject)
import Data.Aeson.Types (withText)
import Data.Text()

data OutputMode = Console | Html deriving (Eq, Show)

data ErrorStyle = ErrorStyle {
  esPrefix    :: String,
  esColor     :: Maybe String, -- color name or hex for html
  esBold      :: Bool,
  esUnderline :: Bool
} deriving (Eq, Show)

data HtmlStyle = HtmlStyle {
  hsFontFamily :: String,
  hsFontSize   :: String,
  hsColor      :: String,
  hsPath       :: FilePath
} deriving (Eq, Show)

data Config = Config {
  cfgMode       :: OutputMode,
  cfgErrorStyle :: ErrorStyle,
  cfgHtml       :: HtmlStyle
} deriving (Eq, Show)

instance FromJSON OutputMode where
  parseJSON = withText "OutputMode" $ \t ->
    if t == "console" then pure Console
    else if t == "html" then pure Html
    else pure Console

instance FromJSON ErrorStyle where
  parseJSON = withObject "ErrorStyle" $ \o -> do
    prefix' <- o .:? "prefix" .!= "*** ERROR: "
    color' <- o .:? "color"
    bold' <- o .:? "bold" .!= True
    underline' <- o .:? "underline" .!= False
    pure ErrorStyle { esPrefix = prefix'
                    , esColor = color'
                    , esBold = bold'
                    , esUnderline = underline' }

instance FromJSON HtmlStyle where
  parseJSON = withObject "HtmlStyle" $ \o -> do
    fontFamily' <- o .:? "font_family" .!= "DejaVu Sans Mono, monospace"
    fontSize' <- o .:? "font_size" .!= "18px"
    color' <- o .:? "color" .!= "#ff5555"
    path' <- o .:? "path" .!= "glados_error.html"
    pure HtmlStyle { hsFontFamily = fontFamily'
                   , hsFontSize = fontSize'
                   , hsColor = color'
                   , hsPath = path' }

instance FromJSON Config where
  parseJSON = withObject "Config" $ \o -> do
    mode' <- o .:? "output_mode" .!= Console
    errorStyle' <- o .:? "error" .!= ErrorStyle "*** ERROR: " (Just "red") True False
    html' <- o .:? "html" .!= HtmlStyle "DejaVu Sans Mono, monospace" "18px" "#ff5555" "glados_error.html"
    pure Config { cfgMode = mode'
                , cfgErrorStyle = errorStyle'
                , cfgHtml = html' }

-- Load configuration from GLADOS_CONFIG, ./glados.config.yaml, or ~/.config/glados/config.yaml
getConfig :: IO Config
getConfig = do
  mPath <- lookupEnv "GLADOS_CONFIG"
  case mPath of
    Just p -> loadOrDefault p
    Nothing -> do
      let local = "glados.config.yaml"
      localExists <- doesFileExist local
      if localExists
        then loadOrDefault local
        else do
          home <- getHomeDirectory
          let dir = home </> ".config" </> "glados"
              path = dir </> "config.yaml"
          exists <- doesFileExist path
          if exists
            then loadOrDefault path
            else pure defaultConfig

loadOrDefault :: FilePath -> IO Config
loadOrDefault fp = do
  eConf <- Y.decodeFileEither fp
  case eConf of
    Right cfg -> pure cfg
    Left _ -> pure defaultConfig

defaultConfig :: Config
defaultConfig = Config {
  cfgMode = Console,
  cfgErrorStyle = ErrorStyle {
    esPrefix = "*** ERROR: ",
    esColor = Just "red",
    esBold = True,
    esUnderline = False
  },
  cfgHtml = HtmlStyle {
    hsFontFamily = "DejaVu Sans Mono, monospace",
    hsFontSize = "18px",
    hsColor = "#ff5555",
    hsPath = "glados_error.html"
  }
}
