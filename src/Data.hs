{-# LANGUAGE OverloadedStrings #-}

module Data where

import           Data.Text                      ( Text )
import           Data.Set                       ( Set )
import           Data.Map                       ( Map )
import           Data.Yaml                      ( FromJSON(..)
                                                , ToJSON(..)
                                                , (.:)
                                                , (.=)
                                                )
import qualified Data.Yaml                     as Y

data PreliminaryProjectConfiguration    = PreliminaryProjectConfiguration
        { preSelectedTemplate :: Maybe Text
        , preTargetDirectory :: Maybe FilePath
        , preSelectedBaseBranch :: Maybe Text
        , preSelectedFeatureBranches :: Maybe (Set Text)
        , preVariableValues :: Maybe (Map Text Text)
        }
        deriving (Show)

data FinalTemplateConfiguration = FinalTemplateConfiguration
        { selectedTemplate :: Text
        , targetDirectory :: FilePath
        }
        deriving (Show)

data FinalProjectConfiguration = FinalProjectConfiguration
        { baseBranch :: Text
        , featureBranches :: Set Text
        , variableValues :: Map Text Text
        }
        deriving (Show)

data TemplateBranchInformation = TemplateBranchInformation
        { branchName :: Text
        , isBaseBranch :: Bool
        , requiredBranches :: Set Text
        , branchVariables :: Map Text Text
        , templateYaml :: TemplateYaml
        }
        deriving (Show)

newtype TemplateInformation = TemplateInformation
        { branchesInformation :: [TemplateBranchInformation]
        }
        deriving (Show)

data TemplateYaml = TemplateYaml
        { variables :: Map Text Text
        , features :: Set Text
        }
        deriving (Show)

instance FromJSON TemplateYaml where
        parseJSON (Y.Object v) =
                TemplateYaml <$> v .: "variables" <*> v .: "features"
        parseJSON _ = fail "Invalid template YAML definition"

instance ToJSON TemplateYaml where
        toJSON TemplateYaml { variables = v, features = f } =
                Y.object ["variables" .= v, "features" .= f]

instance Semigroup TemplateYaml where
        (<>) a b = TemplateYaml { variables = variables a <> variables b
                                , features  = features a <> features b
                                }

instance Monoid TemplateYaml where
        mempty = TemplateYaml { variables = mempty, features = mempty }
