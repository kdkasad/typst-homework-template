#import "../../khw.typ"

#import khw: problem, parts, todo
#import khw: algo, i, d, comment, call

#problem[
  #lorem(20)
]

#parts[
  * #lorem(30) *

  #lorem(50)

  #lorem(10)

  #let sub = math.italic("sub")
  #algo(
    title: "Exponentiate",
    parameters: ("n",),
  )[
    if $n = 0$ then #i \
      return $182$
    #d \

    $#sub <- zwnj$#call("Exponentiate")$(n-1)$ \
    return #call("MulMod")$(sub, sub)$
  ]
][
  * #lorem(12) *

  #lorem(50)

  #lorem(20)

  We will now prove that $E(n) = 182^((2^n)) mod 2000$ using induction.
  Let $P(n)$ be the statement $E(n) = 182^((2^n)) mod 2000$.

  *Basis step:*

  #lorem(20)

  *Inductive step:*

  #lorem(50)

  *Conclusion:*

  Since $P(0)$ is true and $P(n-1) -> P(n)$,
  by induction on $n$, $P(n)$ is true for all $n in NN^+ union {0}$.
]
