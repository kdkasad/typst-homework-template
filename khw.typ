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

// Function to lay out objects in a circle for CeTZ
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

// Function to generate a (di)graph in a radial layout
#let radialgraph = (
  directed: false,
  nodes: (),
  edges: (),
  radius: 1.8cm,
  radial-start: 90deg,
  radial-end: auto,
  text-args: (),
  circle-args: (radius: 0.45cm),
  mark-args: (scale: 1.4),
  style-args: (),
) => {
  cetz.canvas({
    import cetz.draw: *
    set-style(
      stroke: 0.65pt + black,
      ..style-args,
      circle: circle-args,
    )
    if directed {
      set-style(mark: (end: (symbol: ">", fill: black, ..mark-args)))
    }
    radiallayout(
      radius,
      nodes,
      (pos, node) => {
        let (id, label) = if type(node) == array {
          node
        } else {
          (node, node)
        }
        circle(pos, name: id)
        content(id, text(..text-args, label))
      },
      start: radial-start,
      end: radial-end,
    )
    for (src, dsts) in edges {
      let (src, bend) = if type(src) == array {
        src
      } else {
        (src, false)
      }
      if type(dsts) != array {
        dsts = (dsts,)
      }
      for dst in dsts {
        if bend {
          // mid is the point 0.2cm left of the midpoint of the line when facing along the line
          let mid = (
            (src, 50%, dst),
            0.2cm, 90deg,
            dst
          )
          intersections("i",
            src,
            dst,
            hide(arc-through(src, mid, dst))
          )
          arc-through("i.0", mid, "i.1")
        } else {
          line(src, dst)
        }
      }
    }
  })
}
