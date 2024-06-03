#import "../../khw.typ": problem, parts, radialgraph

#problem[
  For the following graph questions, either give an example graph or prove that there are none.
  For parts *(d)* and *(e)*, note that sequence of indegree and outdegree corresponds to the same vertices.
]

#parts[
  *#lorem(10)*
  #h(1fr)

  #figure(
    radialgraph(
      nodes: ("A", "B", "C", "D"),
      edges: (
        ("A", "B"),
        ("B", "C"),
        ("C", "D"),
        ("D", "A"),
        ("A", "C"),
      ),
      radius: 1.8cm,
    ),
    caption: [Graph for problem 4.a.]
  )
][
  *#lorem(12)*
  #h(1fr)

  #figure(
    radialgraph(
      directed: true,
      nodes: ("A", "B", "C", "D"),
      edges: (
        ("D", ("A", "B", "C")),
        ("A", ("B", "C")),
        ("B", ("A", "C")),
        ("C", ("A", "B")),
      ),
    ),
    caption: [Graph for problem 4.b.]
  )
][
  *#lorem(15)*
  #h(1fr)

  #figure(
    radialgraph(
      nodes: ("A", "B", "C", "D", "E"),
      edges: (
        ("A", ("B", "C", "D", "E")),
        ("B", ("C", "D", "E")),
        ("C", ("D", "E")),
        ("D", "E"),
      ),
      radius: 2cm
    ),
    caption: [Graph for problem 4.c.]
  )
]
