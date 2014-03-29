-- Copyright (c) 2014, Birte Wagner, Sebastian Philipp
--

module RTree where

import Data.Function
import Control.Applicative ((<$>))

type Point = (Double, Double)

type Rect = (Point, Point)
type MBB = Rect

data RTree a = 
      Node {getMBB :: MBB, getChilderen :: [RTree a] }
    | Leaf {getMBB :: MBB, getElem :: a}

m = 5
n = 10
order = (m, n)

empty :: RTree a
empty = undefined -- Node []

singleton :: MBB -> a -> RTree a
singleton mbb x = Leaf mbb x

calcMBB :: RTree a -> MBB
calcMBB (Node _ x) = calcMBB' $ calcMBB <$> x 
calcMBB (Leaf bb x) = bb

calcMBB' :: [MBB] -> MBB
calcMBB' [] = error "no MBB"
calcMBB' [x] = x
calcMBB' ((ul,br):xs) = (minUl, maxBr)
    where
    (ul', br') = calcMBB' xs
    minUl :: Point
    minUl = ((min `on` fst) ul ul', (min `on` snd) ul ul')
    maxBr :: Point
    maxBr = ((max `on` fst) br br', (max `on` snd) br br')

validRtree :: RTree a -> Bool
validRtree (Leaf mbb _) = True
validRtree x@(Node mbb c) = length c >= 2 && (and $ validRtree <$> c) && (isBalanced x)

depth :: RTree a -> Int
depth (Leaf _ _ ) = 0
depth (Node _ c) = 1 + (depth $ head c)

isBalanced :: RTree a -> Bool 
isBalanced (Leaf _ _ ) = True
isBalanced (Node _ c) = (and $ isBalanced <$> c) && (and $ (== depth (head c)) <$> (depth <$> c))

lookup :: a -> RTree a -> a
lookup = undefined

length' :: RTree a -> Int 
length' (Leaf {}) = 1
length' (Node _ c) = sum $ length' <$> c

insert :: a -> RTree a
insert = undefined


addLeaf :: RTree a -> RTree a -> RTree a
addLeaf newLeaf@Leaf{} old = Node (calcMBB' [getMBB newLeaf, getMBB old]) (newLeaf : getChilderen old)
addLeaf _ _ = error "addLeaf: node"

insertLeaf :: RTree a -> [RTree a] -> [RTree a]
insertLeaf newLeaf oldC = findNodeWithMinimalAreaIncrease (maybeSplitNode . addLeaf newLeaf) (getMBB newLeaf) oldC

findNodeWithMinimalAreaIncrease :: (RTree a -> [RTree a]) -> MBB -> [RTree a] -> [RTree a]
findNodeWithMinimalAreaIncrease f mbb xs = concat $ xsAndIncrease'
    where
--    xsAndIncrease :: [(RTree a, Double)]    
    xsAndIncrease = zip xs ((areaIncreasesWith mbb) <$> xs)
    minimalIncrease = minimum $ snd <$> xsAndIncrease
--    xsAndIncrease' :: [(RTree a, Double)]    
    xsAndIncrease' = map mapIf xsAndIncrease
    mapIf (x, increase) = if increase == minimalIncrease then
            f x
        else
            [x]


adjustTree :: [RTree a] -> [RTree a]
adjustTree inNodes = undefined
    where
    inNodes' = undefined -- insert'
    splitted = case maybeSplitNode of
        [c1, c2] ->  undefined
        [c1] -> undefined


maybeSplitNode :: RTree a -> [RTree a]
maybeSplitNode x
    | (length $ getChilderen x) > n = splitNode x
    | otherwise = [x]


-- how to split?
splitNode :: RTree a -> [RTree a]
splitNode = undefined

mergeNodes :: RTree a -> RTree a -> RTree a
mergeNodes (Node mbb1 c1) (Node mbb2 c2) = Node (calcMBB' [mbb1, mbb2]) (c1 ++ c2)
mergeNodes _ _ = error "no merge for Leafs"
-- ------------
-- helpers

area :: MBB -> Double
area ((x1, y1), (x2, y2)) = (x2 - x1) * (y2 - y1)

areaIncreasesWith :: MBB -> (RTree a) -> Double
areaIncreasesWith newElem current = newArea - currentArea
    where
    currentArea = area $ getMBB current
    newArea = area $ calcMBB' [newElem, getMBB current]
