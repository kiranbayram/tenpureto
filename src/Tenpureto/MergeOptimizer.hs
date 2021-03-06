module Tenpureto.MergeOptimizer where

import           Data.List
import qualified Data.Set                      as Set
import           Data.Graph

import           Tenpureto.TemplateLoader       ( TemplateInformation(..)
                                                , TemplateBranchInformation(..)
                                                )

import           Debug.Trace

reorderBranches :: [TemplateBranchInformation] -> [TemplateBranchInformation]
reorderBranches branches =
    let edge bi = (bi, branchName bi, Set.toList (requiredBranches bi))
        (graph, nodeFromVertex, _) = graphFromEdges (fmap edge branches)
        topo                       = topSort graph
        fst3 (a, _, _) = a
    in  fmap (fst3 . nodeFromVertex) topo

includeMergeBranches
    :: TemplateInformation
    -> [TemplateBranchInformation]
    -> [TemplateBranchInformation]
includeMergeBranches template branches =
    let
        allBranches  = branchesInformation template
        mergeOptions = filter ((<) 1 . length) (subsequences branches)
        isMergeOf bi bis = foldMap requiredBranches bis == requiredBranches bi
        isMerge bi = any (isMergeOf bi) mergeOptions
    in
        nub $ branches ++ filter isMerge allBranches
