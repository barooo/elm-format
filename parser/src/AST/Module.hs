module AST.Module
    ( Module(..), Header(..), SourceTag(..)
    , UserImport(..), ImportMethod(..)
    ) where

import qualified AST.Declaration as Declaration
import qualified AST.Module.Name as Name
import qualified AST.Variable as Var
import qualified Reporting.Annotation as A
import AST.V0_16


-- MODULES


data Module = Module
    { initialComments :: Comments
    , header :: Header
    , docs :: A.Located (Maybe String)
    , imports :: [UserImport]
    , body :: [Declaration.Decl]
    }
    deriving (Eq, Show)


instance A.Strippable Module where
  stripRegion m =
    Module
    { initialComments = initialComments m
    , header =
        Header
          { srcTag = srcTag $ header m
          , name = name $ header m
          , moduleSettings = moduleSettings $ header m
          , exports = exports $ header m
          }
    , docs = A.stripRegion $ docs m
    , imports = imports m
    , body = map A.stripRegion $ body m
    }


-- HEADERS

data SourceTag
  = Normal
  | Effect Comments
  | Port Comments
  deriving (Eq, Show)


{-| Basic info needed to identify modules and determine dependencies. -}
data Header = Header
    { srcTag :: SourceTag
    , name :: Commented Name.Raw
    , moduleSettings :: Maybe (KeywordCommented SourceSettings)
    , exports :: KeywordCommented (Var.Listing Var.Value)
    }
    deriving (Eq, Show)


type SourceSettings =
  [(Commented String, Commented String)]

-- IMPORTs

data UserImport
    = UserImport (A.Located (PreCommented Name.Raw, ImportMethod))
    | ImportComment Comment
    deriving (Eq, Show)


data ImportMethod = ImportMethod
    { alias :: Maybe (Comments, PreCommented String)
    , exposedVars :: (Comments, PreCommented (Var.Listing Var.Value))
    }
    deriving (Eq, Show)
