#import "../../khw.typ": problem, parts, boxed

#problem(newpage: false)[
  Consider the given code segment. _(Omitted here.)_
]

#parts[
  *When $f(k)$ is called,
  how many times is it recursively called in total?
  Include the initial call and give the answer in terms of $k$.*

  $f(k)$ calls $f(k-1)$ recursively until the argument equals 0.
  Thus the number of times $f(k)$ is called is
  $T(k) = T(k-1) + 1$, $T(0) = 1$.

  $
  T(k)
  &= T(k-1) + 1 \
  &= T(k-2) + 1 + 1 \
  &= T(k-3) + 1 + 1 + 1 \
  &= T(k-n) + n \
  &= T(0) + k && "when" n = k \
  T(k) &= k + 1
  $
][
  *What does $f(k)$ return?
  Give your answer in terms of $k$.*

  Based on the code, we can define $f(k)$ mathematically as
  $f(k) = f(k-1) + 3k + 2, f(0)=2$.

  $
  f(k) &= f(k-1) + 3k + 2 \
  &= (f(k-2) + 3(k-1) + 2) + 3k + 2 \
  &= ((f(k-3) + 3(k-2) + 2) + 3(k-1) + 2) + 3k + 2 \
  &= f(k-3) + 3(k-2) + 2 + 3(k-1) + 2 + 3k + 2 \
  &= f(k-n) + 3 sum_(i=k-n+1)^(k) i + n(2) \
  $

  Now let $n=k$.

  $
  f(k) &= f(0) + 3 sum_(i=1)^(k) i + 2k \
  &= 2 + 3 dot k(k+1)/2 + 2k \
  // &= (4+3k^2+3k+4k)/2 \
  f(k) &= (3k^2 + 7k + 4)/2
  $
][
  *How many times is $f$ called in total?
  Give the answer in terms of $n$.*

  $f(j)$ is called once from each iteration of the loop.
  The loop runs from $j=1$ to $j=n$.
  Thus the number of times $f$ is called is the following sum,
  where $T(n)$ represents the number of times $f$ is called when invoked as $f(n)$.
  We know from part *(a)* that $T(n) = n+1$.

  $
  sum_(j=1)^(n) T(j)
  &= sum_(j=1)^n (j+1)
  = sum_(j=1)^n j + sum_(j=1)^n 1
  = n(n+1)/2 + n
  = (n^2 + 3n)/2
  $
]
