#import "../../khw.typ": problem, radialgraph

#problem[
  #lorem(70)
]

Proof by cases.
Below, a node in a graph represents a TA and an edge between two nodes represents a handshake between the two TAs.

=== Case 1: Everyone shook hands

#lorem(50)

=== Case 2: Not everyone shook hands

#lorem(60)

#lorem(80)

#grid(
  columns: 2,
  column-gutter: 1cm,
  [#figure(
    radialgraph(
      radius: 1.5cm,
      nodes: ("A", "B", "C", "D"),
      edges: (
        ("A", ("C", "D")),
        ("B", ("C", "D")),
      )
    ),
    caption: [
      A graph which demonstrates that having two disjoint pairs of TAs who have not shaken hands contradicts UTA Bob's observation and thus is impossible.
      ${A, B}$ and ${C, D}$ are the pairs of TAs who have not shaken hands.
    ]
  ) <fig:two-disjoint-pairs>],
  [#figure(
    radialgraph(
      radius: 1.5cm,
      nodes: ("A", "B", "C", "D"),
      edges: (
        ("C", ("A", "B", "D")),
      )
    ),
    caption: [
      A graph which demonstrates that having two pairs of TAs who have not shaken hands is possible as long as one TA is in both pairs.
      ${A, B}$ and ${A, D}$ are the pairs of TAs who have not shaken hands.
    ]
  ) <fig:two-overlapping-pairs>]
)

#lorem(20)
@fig:two-overlapping-pairs demonstrates that this still satisfies UTA Bob's observation, so it can exist.

#lorem(50)

#lorem(40)
