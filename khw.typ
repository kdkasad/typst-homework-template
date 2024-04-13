//
// Kian's Typst homework template
//
// Copyright 2024  Kian Kasad  (kian@kasad.com)
//
// This code is made available under the terms of 3-Clause BSD License.
// See the LICENSE file included in this repository.
// SPDX-License-Identifier: BSD-3-Clause
//

#import "@preview/cetz:0.2.2"
#import "@preview/algo:0.3.3": algo, comment, i, d

// Stateful variable to control whether problems
// appear on new pages
#let _khw-newpages = state("_khw:newpages", false)

// Stateful variable to control the default problem name
#let _khw-problem-name = state("_khw:problem-name", "Problem")

// Todo macro
#let todo = box(
  stroke: red,
  outset: 4pt,
  [To do...]
)

// Boxed function
#let boxed = box.with(
  stroke: 0.4pt + black,
  outset: 3pt
)

// Customized version of algo() from @preview/algo
#let algo = (..args, body) => {
  let named = args.named()

  // Add bold "procedure" in front of algorithm title
  if named.at("header", default: none) == none {
    let title = named.at("title")
    if type(title) == "string" {
      title = underline(smallcaps(title))
    }
    title = [*procedure* ] + title
    named.insert("title", title)
  }
  args = arguments(..named, ..args.pos())

  // Call underlying algo() function from @preview/algo
  algo(
    block-align: none,
    stroke: 0.5pt + black,
    row-gutter: 8pt,
    indent-guides: 0.4pt + black,
    indent-guides-offset: 2pt,
    ..args,
    body + h(1fr) // To make algo box take full text width
  )
}
#let call = smallcaps // Helper for calling functions

// Problem function
#let _khw-problem-number = counter("_khw:problem-number")
#let problem = (
  name: auto,
  newpage: auto,
  increment: 1,
  label: none,
  content
) => {
  // Increment counter
  _khw-problem-number.update(n => n + increment)

  // Page break if requested
  context if ((newpage == auto) and (_khw-newpages.get() == true)) or (newpage == true) {
    pagebreak(weak: true)
  }

  // Line above
  line(length: 100%, stroke: 0.4pt)
  v(-6pt)

  // Problem heading/number and text
  let problem-numbering = (..nums) => {
    if name == auto {
      _khw-problem-name.display()
    } else {
      name
    } + numbering(" 1.", ..nums)
  }
  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    [#heading(
      numbering: problem-numbering,
      outlined: true,
      bookmarked: false,
      supplement: none,
      none
    ) #label],
    content
  )

  // Line below
  v(-6pt)
  line(length: 100%, stroke: 0.4pt)
}


// Problem parts function
#let parts = (..args) => {
  enum(
    numbering: (..nums) => [*#numbering("(a.i)", ..nums)*],
    tight: false,
    ..args.named(),
    ..args.pos().map(it => {
      if type(it) == content {
        set enum(numbering: "i)")
        block(breakable: false, it)
      } else {
        it
      }
    })
  )
}


// Document template function
#let khw(
  title: none,
  course: none,
  author: none,
  date: datetime.today(),
  newpages: false,
  problem-name: "Problem",
  doc
) = {
  // This has to be the first thing in the function body
  set page(
    paper: "us-letter",
    margin: 1in,
    numbering: "1",
  )

  // Save the value of newpages
  if newpages {
    _khw-newpages.update(true)
  }

  // Save the value of problem-name
  _khw-problem-name.update(problem-name)

  set text(
    font: "EB Garamond",
    size: 11pt,
    number-type: "lining",
    stylistic-set: 06,
  )

  set par(
    leading: 5pt,
  )

  // Smaller figure captions
  show figure.caption: it => text(size: text.size - 1.5pt, it)


  set align(center)

  // Title
  assert(title != none)
  text(size: 18pt, weight: "medium", title)
  linebreak()

  // Course
  if course != none {
    text(size: 14pt, course)
    linebreak()
  }

  // Author
  if author != none {
    author
    linebreak()
  }

  // Date
  let nicedate = date.display("[month repr:long] [day padding:none], [year]")
  if date != none {
    nicedate
    linebreak()
  }

  parbreak()

  // Heading style
  show heading.where(level: 1): it => {
    text(size: 11pt, weight: "bold", it)
  }

  // Rest of document
  set align(left)
  set par(justify: true)
  set pagebreak(weak: true)
  show "%%author%%": author
  show "%%title%%": title
  show "%%date%%": nicedate
  doc
}

// Alias for khw
#let doc = khw

// Function to lay out objects in a circle for CeTZ.
// The objects and method used to draw them are completely generic.
//
// Parameters:
//
//   radius: length
//   Radius of the circle in which to lay out the objects.
//
//   items: array
//   Array of objects to lay out.
//
//   draw_item: function (coordinate, item) => ()
//   Callback function used to draw each item.
//   This callback takes two arguments (in this order): the coordinate at which
//   to draw the object, and the object to draw.
//   This function is called for each element of the "items" array.
//
//   start: angle [default: 90deg]
//   The angle at which the first item will be placed. The angle is measured
//   counterclockwise from the east direction.
//
//   end: angle [default: auto]
//   The angle at which the last item will be placed. The angle is measured
//   counterclockwise from the east direction. If set to auto, a default of
//   (start + 360deg) is used.
#let radiallayout = (
  radius,
  items,
  draw_item,
  start: 90deg,
  end: auto,
) => {
  if end == auto {
    end = start + 360deg
  }
  import cetz.draw: *
  let n = items.len()
  let delta = (end - start) / n
  for i in range(n) {
    let item = items.at(i)
    // CeTZ uses (angle, radius) instead of (radius, angle)
    draw_item((start + i * delta, radius), item)
  }
}

// Function to generate a (di)graph in a radial layout.
// Each node in the graph is placed along a circle, and edges are drawn between
// them as specified.
//
// Parameters:
//
//   directed: bool [default: false]
//   Whether or not the graph is directed. If true, arrows will be drawn at the
//   destination end of each edge.
//
//   overlay: bool [default: false]
//   Whether to overlap multiple edges between the same nodes. If true, edges
//   will be overlapped, i.e. multiple edges will appear as one edge. If false,
//   each successive edge will be bent so it is distinguishable from the other
//   edges.
//
//   nodes: array of strings or array of (string, string) pairs [default: ()]
//   Specifies the nodes of the graph.
//   Each element describes a node. A single string is used as both the ID and
//   the label for the node. A pair of strings, i.e. an array of length 2,
//   specifies the ID and the label for the node, in that order.
//
//   edges: array of (string, string) or (string, array of strings) pairs [default: ()]
//   Specifies the edges of the graph.
//   Each element is a pair. The first element of this pair is the ID of the
//   source node for an edge. The second element is either the destination
//   node's ID, or an array of IDs, in which case an edge will be drawn from the
//   source to each destination.
//
//   radius: length [default: 1.8cm]
//   The radius of the circle on which the nodes will be placed.
//
//   radial-start: angle [default: 90deg]
//   The angle at which the first node will be placed. The angle is measured
//   counterclockwise from the east direction.
//
//   radial-end: angle [default: auto]
//   The angle at which the last node will be placed. The angle is measured
//   counterclockwise from the east direction. If set to auto, a default of
//   (radial-start + 360deg) is used.
//
//   text-args: dictionary [default: (:)]
//   Additional arguments to be passed to Typst's text() function for the node
//   labels.
//
//   circle-args: dictionary [default: (radius: 0.45cm)]
//   Additional arguments to be passed to CeTZ's cetz.draw.circle() function
//   used to draw each node.
//
//   mark-args: dictionary [default: (symbol: ">", fill: black, scale: 1.4)]
//   Additional arguments used to configure the arrowheads on directed edges.
//   It is used as follows:
//     cetz.draw.set-style(mark: (start: mark-args, end: mark-args))
//
//   style-args: dictionary [default: (:)]
//   Additional arguments to be passed to CeTZ's cetz.draw.set-style() function.
//
//   additional-content: array [default: ()]
//   Additional content to be drawn after the graph is drawn. Accepts a code
//   block in which cetz.draw.* functions can be called. I.e. this argument
//   should be the same as the argument to cetz.canvas().
#let radialgraph = (
  directed: false,
  overlay: false,
  nodes: (),
  edges: (),
  radius: 1.8cm,
  radial-start: 90deg,
  radial-end: auto,
  text-args: (:),
  circle-args: (radius: 0.45cm),
  mark-args: (symbol: ">", fill: black, scale: 1.4),
  style-args: (:),
  additional-content: (),
) => {
  // Create drawing
  cetz.canvas({
    import cetz.draw: *

    // Set style of elements
    set-style(
      stroke: 0.65pt + black, // Default stroke
      ..style-args, // User-supplied style specifications
      circle: circle-args, // Circle style (for nodes)
    )

    // Convert all nodes in list from strings to tuples (id, label) if necessary
    nodes = nodes.map(node-spec => {
      if type(node-spec) != array {
        (node-spec, node-spec)
      } else {
        node-spec.slice(0, 2)
      }
    })

    // Function to draw a node.
    // Takes a position and a node, which can be a string or a tuple (id, label)
    let draw-node = (pos, (node-id, node-label)) => {
      circle(pos, name: node-id)
      content(node-id, text(..text-args, node-label))
    }

    // Lay out nodes using radiallayout() and draw-node()
    radiallayout(
      radius,
      nodes,
      draw-node,
      start: radial-start,
      end: radial-end,
    )

    // Dictionary matrix which represents the graph graph-matrix.at(x).at(y) (x
    // and y are node IDs) is a tuple of (count, drawn), where count is the
    // number of edges from x to y and drawn is the number of those that have
    // been drawn.
    let graph-matrix = (:)
    for (from-id, _) in nodes {
      graph-matrix.insert(from-id, (:))
      for (to-id, _) in nodes {
        graph-matrix.at(from-id).insert(to-id, (0, 0))
      }
    }

    // Convert all destinations to arrays
    edges = edges.map(((src, dst-spec)) => {
      if type(dst-spec) != array {
        dst-spec = (dst-spec,)
      }
      (src, dst-spec)
    })

    // Iterate through edge specifications
    for (src, dst-spec) in edges {
      // Panic if the source or destinations are not in the list of nodes
      let node-ids = nodes.map(it => it.at(0))
      for node in (src, ..dst-spec) {
        if not node-ids.contains(node) {
          panic("Node " + node + "used in edge list but not found in list of nodes")
        }
      }

      // Add each edge to the graph matrix
      for dst in dst-spec {
        graph-matrix.at(src).at(dst).at(0) += 1
      }
    }

    // Draw edges
    for (src, dest-spec) in edges {
      for dst in dest-spec {
        // Get the number of edges between src and dst. "count" will be the total
        // number of edges to be drawn between these nodes (in both directions),
        // and "drawn" will be the number already drawn.
        let (count, drawn) = graph-matrix.at(src).at(dst)
        let (rcount, rdrawn) = graph-matrix.at(dst).at(src)
        count += rcount
        drawn += rdrawn

        // To properly bend edges, we have to make all edges go in the same
        // direction. To do this, we make every edge go from the node with the
        // lesser ID to the node with the greater ID.
        let reverse = false
        if src < dst {
          (src, dst) = (dst, src)
          reverse = true
        }

        // From here on, we can use "drawn" as the index of the current edge
        // being drawn (starting at 0)

        // Calculate the bend of this edge
        let bend-step = 0.2cm
        let (offset, angle) = if calc.rem(count, 2) == 0 {
          // Even total number of edges: every edge is bent
          let pair = calc.quo(drawn, 2) + 1 // The index of the pair this edge belongs to, starting at 1
          if calc.rem(drawn, 2) == 0 {
            // Even index edge, bends left
            (bend-step * pair, 90deg)
          } else {
            // Odd index edge, bends right
            (bend-step * pair, -90deg)
          }
        } else {
          // Odd total number of edges: first edge is straight, all other edges are bent
          let pair = calc.quo(drawn - 1, 2) + 1 // The index of the pair this edge belongs to, starting at 1
          if drawn == 0 {
            // First edge is straight
            (0, 0deg)
          } else if calc.rem(drawn - 1, 2) == 0 {
            // Even index edge
            (bend-step / 2 + bend-step * pair, 90deg)
          } else {
            // Odd index edge
            (bend-step / 2 + bend-step * pair, -90deg)
          }
        }

        if directed {
          let key = if reverse {
            "start"
          } else {
            "end"
          }
          let mark-arg-dict = (start: (), end: ())
          mark-arg-dict.insert(key, mark-args)
          set-style(mark: mark-arg-dict)
        }

        // Arc functions fail if the midpoint is on a straight line, so we must check for that
        if (overlay == true) or (offset == 0) or (angle == 0) {
          line(src, dst)
        } else {
          // Calculate midpoint of the edge using interpolation coordinates
          let midpoint = (
            (src, 50%, dst), // Midpoint of the line from src to dst
            offset, angle,
            dst
          )

          // Draw an invisible arc from src to dst through the midpoint, and
          // find the points where it intersects the borders of src and dst.
          intersections("i",
            src,
            dst,
            hide(arc-through(src, midpoint, dst))
          )

          // Draw the arc between the two intersection points, passing through
          // the midpoint.
          arc-through("i.0", midpoint, "i.1")
        }

        // Once we've drawn our edge, increment the drawn count
        graph-matrix.at(src).at(dst).at(1) += 1

        // If we swapped the src and dst, swap them back before processing the next edge
        if reverse {
          (src, dst) = (dst, src)
        }

      }
    }

    additional-content
  })
}
