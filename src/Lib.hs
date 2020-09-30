{-# LANGUAGE LambdaCase #-}
module Lib ( appMain ) where

import           Data.Hourglass
import           Data.List
import           Data.List.Split
import           Text.Read
import           Time.System

data Work
  = Work
  { workName :: String -- ^ この程度の効率を気にしないプログラムでTextを持ち出すのは面倒になった
  , workTime :: Seconds
  }
  deriving (Eq, Ord, Read, Show)

appMain :: IO ()
appMain = do
  contents <- getContents
  date <- dtDate <$> dateCurrent
  works <- mapM (\case Left msg -> fail msg -- もうちょい綺麗に書けないかな, fromRightは何故かダメでした…
                       Right work -> pure work
                ) $ parseWork date <$> wordsBy (\c -> c == ',' || c == '\n') contents
  putStr $ workgroupPrettyStr $ collectWorkGroup works

parseWork :: Date -> String -> Either String Work
parseWork date str
  = case words str of
      startStr : endStr : tl ->
        let parse source = case splitOn ":" source of
              [hs, ss] -> do
                h <- readMaybe hs
                s <- readMaybe ss
                pure $ DateTime date TimeOfDay{todHour = Hours h, todMin = Minutes s, todSec = 0, todNSec = 0}
              _ -> Nothing
            leftParse s =  Left $ "次の時刻表記が認識できませんでした: " <> s
        in case (parse startStr, parse endStr) of
          (Just workStart, Just workEnd) -> Right Work{workName = concat tl, workTime = workEnd `timeDiff` workStart}
          (Nothing, Just _) -> leftParse startStr
          (Just _, Nothing) -> leftParse endStr
          (Nothing, Nothing) -> leftParse $ startStr <> " && " <> endStr
      _ -> Left $ "文字列を認識できませんでした: " <> str

collectWorkGroup :: [Work] -> [Work]
collectWorkGroup = foldr addWork []

addWork :: Work -> [Work] -> [Work]
addWork work works = case find (\w -> workName w == workName work) works of
  Nothing -> work : works
  Just progressWork
    -> Work{workName = workName work, workTime = workTime progressWork + workTime work} :
       progressWork `delete` works

workgroupPrettyStr :: [Work] -> String
workgroupPrettyStr works = unlines (workPrettyStr <$> works)

workPrettyStr :: Work -> String
workPrettyStr work
  = case fromSeconds (workTime work) of
      (d, 0) ->
        concatMap (++ "\t")
        [ workName work
        , show (toInteger $ durationHours d) <> ":" <> show (toInteger $ durationMinutes d)
        , show (fromIntegral (toInteger (durationHours d)) + (fromIntegral (toInteger (durationMinutes d)) / (60 :: Double)))
        ]
      o -> error $ "出力がヘンになりました: " <> show o
