
module Tactic.Reflection.Equality where

open import Prelude
open import Builtin.Reflection
open import Builtin.Float

instance
  EqVisibility : Eq Visibility
  EqVisibility = record { _==_ = eqVis }
    where
      eqVis : ∀ x y → Dec (x ≡ y)
      eqVis visible  visible  = yes refl
      eqVis visible  hidden   = no (λ ())
      eqVis visible  instance′ = no (λ ())
      eqVis hidden   visible  = no (λ ())
      eqVis hidden   hidden   = yes refl
      eqVis hidden   instance′ = no (λ ())
      eqVis instance′ visible  = no (λ ())
      eqVis instance′ hidden   = no (λ ())
      eqVis instance′ instance′ = yes refl

  EqRelevance : Eq Relevance
  EqRelevance = record { _==_ = eqRel }
    where
      eqRel : ∀ x y → Dec (x ≡ y)
      eqRel relevant   relevant   = yes refl
      eqRel relevant   irrelevant = no (λ ())
      eqRel irrelevant relevant   = no (λ ())
      eqRel irrelevant irrelevant = yes refl

  EqArgInfo : Eq ArgInfo
  EqArgInfo = record { _==_ = eqArgInfo }
    where
      eqArgInfo : ∀ x y → Dec (x ≡ y)
      eqArgInfo (arg-info v r) (arg-info v₁ r₁) =
        decEq₂ arg-info-inj₁ arg-info-inj₂ (v == v₁) (r == r₁)

  EqArg : ∀ {A} {{EqA : Eq A}} → Eq (Arg A)
  EqArg = record { _==_ = eqArg }
    where
      eqArg : ∀ x y → Dec (x ≡ y)
      eqArg (arg i x) (arg i₁ x₁) = decEq₂ arg-inj₁ arg-inj₂ (i == i₁) (x == x₁)

  EqLiteral : Eq Literal
  EqLiteral = record { _==_ = eqLit }
    where
      eqLit : ∀ x y → Dec (x ≡ y)
      eqLit (nat    x) (nat    y) = decEq₁ nat-inj    (x == y)
      eqLit (float  x) (float  y) = decEq₁ float-inj  (x == y)
      eqLit (char   x) (char   y) = decEq₁ char-inj   (x == y)
      eqLit (string x) (string y) = decEq₁ string-inj (x == y)
      eqLit (name   x) (name   y) = decEq₁ name-inj   (x == y)

      eqLit (nat    x) (float  y) = no λ()
      eqLit (nat    x) (char   y) = no λ()
      eqLit (nat    x) (string y) = no λ()
      eqLit (nat    x) (name   y) = no λ()
      eqLit (float  x) (nat    y) = no λ()
      eqLit (float  x) (char   y) = no λ()
      eqLit (float  x) (string y) = no λ()
      eqLit (float  x) (name   y) = no λ()
      eqLit (char   x) (nat    y) = no λ()
      eqLit (char   x) (float  y) = no λ()
      eqLit (char   x) (string y) = no λ()
      eqLit (char   x) (name   y) = no λ()
      eqLit (string x) (nat    y) = no λ()
      eqLit (string x) (float  y) = no λ()
      eqLit (string x) (char   y) = no λ()
      eqLit (string x) (name   y) = no λ()
      eqLit (name   x) (nat    y) = no λ()
      eqLit (name   x) (float  y) = no λ()
      eqLit (name   x) (char   y) = no λ()
      eqLit (name   x) (string y) = no λ()

private
  eqSort : (x y : Sort) → Dec (x ≡ y)
  eqTerm : (x y : Term) → Dec (x ≡ y)
  eqType : (x y : Type) → Dec (x ≡ y)

  eqArgType : (x y : Arg Type) → Dec (x ≡ y)
  eqArgType (arg i x) (arg i₁ x₁) = decEq₂ arg-inj₁ arg-inj₂ (i == i₁) (eqType x x₁)

  eqArgTerm : (x y : Arg Term) → Dec (x ≡ y)
  eqArgTerm (arg i x) (arg i₁ x₁) = decEq₂ arg-inj₁ arg-inj₂ (i == i₁) (eqTerm x x₁)

  eqArgs : (x y : List (Arg Term)) → Dec (x ≡ y)
  eqArgs [] [] = yes refl
  eqArgs [] (x ∷ xs) = no λ ()
  eqArgs (x ∷ xs) [] = no λ ()
  eqArgs (x ∷ xs) (y ∷ ys) = decEq₂ cons-inj-head cons-inj-tail (eqArgTerm x y) (eqArgs xs ys)

  eqTerm (var x args) (var x₁ args₁) = decEq₂ var-inj₁ var-inj₂ (x == x₁) (eqArgs args args₁)
  eqTerm (con c args) (con c₁ args₁) = decEq₂ con-inj₁ con-inj₂ (c == c₁) (eqArgs args args₁)
  eqTerm (def f args) (def f₁ args₁) = decEq₂ def-inj₁ def-inj₂ (f == f₁) (eqArgs args args₁)
  eqTerm (lam v x) (lam v₁ y) = decEq₂ lam-inj₁ lam-inj₂ (v == v₁) (eqTerm x y)
  eqTerm (pi t₁ t₂) (pi t₃ t₄) = decEq₂ pi-inj₁ pi-inj₂ (eqArgType t₁ t₃) (eqType t₂ t₄)
  eqTerm (sort x) (sort x₁) = decEq₁ sort-inj (eqSort x x₁)
  eqTerm (lit l) (lit l₁)   = decEq₁ lit-inj (l == l₁)
  eqTerm unknown unknown = yes refl

  eqTerm (var x args) (con c args₁) = no λ ()
  eqTerm (var x args) (def f args₁) = no λ ()
  eqTerm (var x args) (lam v y) = no λ ()
  eqTerm (var x args) (pi t₁ t₂) = no λ ()
  eqTerm (var x args) (sort x₁) = no λ ()
  eqTerm (var x args) (lit x₁) = no λ ()
  eqTerm (var x args) unknown = no λ ()
  eqTerm (con c args) (var x args₁) = no λ ()
  eqTerm (con c args) (def f args₁) = no λ ()
  eqTerm (con c args) (lam v y) = no λ ()
  eqTerm (con c args) (pi t₁ t₂) = no λ ()
  eqTerm (con c args) (sort x) = no λ ()
  eqTerm (con c args) (lit x) = no λ ()
  eqTerm (con c args) unknown = no λ ()
  eqTerm (def f args) (var x args₁) = no λ ()
  eqTerm (def f args) (con c args₁) = no λ ()
  eqTerm (def f args) (lam v y) = no λ ()
  eqTerm (def f args) (pi t₁ t₂) = no λ ()
  eqTerm (def f args) (sort x) = no λ ()
  eqTerm (def f args) (lit x) = no λ ()
  eqTerm (def f args) unknown = no λ ()
  eqTerm (lam v x) (var x₁ args) = no λ ()
  eqTerm (lam v x) (con c args) = no λ ()
  eqTerm (lam v x) (def f args) = no λ ()
  eqTerm (lam v x) (pi t₁ t₂) = no λ ()
  eqTerm (lam v x) (sort x₁) = no λ ()
  eqTerm (lam v x) (lit x₁) = no λ ()
  eqTerm (lam v x) unknown = no λ ()
  eqTerm (pi t₁ t₂) (var x args) = no λ ()
  eqTerm (pi t₁ t₂) (con c args) = no λ ()
  eqTerm (pi t₁ t₂) (def f args) = no λ ()
  eqTerm (pi t₁ t₂) (lam v y) = no λ ()
  eqTerm (pi t₁ t₂) (sort x) = no λ ()
  eqTerm (pi t₁ t₂) (lit x) = no λ ()
  eqTerm (pi t₁ t₂) unknown = no λ ()
  eqTerm (sort x) (var x₁ args) = no λ ()
  eqTerm (sort x) (con c args) = no λ ()
  eqTerm (sort x) (def f args) = no λ ()
  eqTerm (sort x) (lam v y) = no λ ()
  eqTerm (sort x) (pi t₁ t₂) = no λ ()
  eqTerm (sort x) (lit x₁) = no λ ()
  eqTerm (sort x) unknown = no λ ()
  eqTerm (lit x) (var x₁ args) = no λ ()
  eqTerm (lit x) (con c args) = no λ ()
  eqTerm (lit x) (def f args) = no λ ()
  eqTerm (lit x) (lam v y) = no λ ()
  eqTerm (lit x) (pi t₁ t₂) = no λ ()
  eqTerm (lit x) (sort x₁) = no λ ()
  eqTerm (lit x) unknown = no λ ()
  eqTerm unknown (var x args) = no λ ()
  eqTerm unknown (con c args) = no λ ()
  eqTerm unknown (def f args) = no λ ()
  eqTerm unknown (lam v y) = no λ ()
  eqTerm unknown (pi t₁ t₂) = no λ ()
  eqTerm unknown (sort x) = no λ ()
  eqTerm unknown (lit x) = no λ ()

  eqTerm _ _ = todo "extended lambda"
    where postulate todo : String → _

  eqSort (set t) (set t₁) = decEq₁ set-inj (eqTerm t t₁)
  eqSort (lit n) (lit n₁) = decEq₁ slit-inj (n == n₁)
  eqSort unknown unknown = yes refl
  eqSort (set t) (lit n) = no λ ()
  eqSort (set t) unknown = no λ ()
  eqSort (lit n) (set t) = no λ ()
  eqSort (lit n) unknown = no λ ()
  eqSort unknown (set t) = no λ ()
  eqSort unknown (lit n) = no λ ()

  eqType (el s t) (el s₁ t₁) = decEq₂ el-inj₁ el-inj₂ (eqSort s s₁) (eqTerm t t₁)

instance
  EqType : Eq Type
  EqType = record { _==_ = eqType }

  EqTerm : Eq Term
  EqTerm = record { _==_ = eqTerm }
