//
// Kian's Typst homework template
//
// Copyright 2024  Kian Kasad  (kian@kasad.com)
//
// This code is made available under the terms of 3-Clause BSD License.
// See the LICENSE file included in this repository.
// SPDX-License-Identifier: BSD-3-Clause
//

// Stateful variable to control whether problems
// appear on new pages
#let khw-newpages = state("khw:newpages", none)

// Stateful variable to control the default problem name
#let khw-problemname = state("khw:problemname", "Problem")

// Todo macro
#let todo = box(
  stroke: red,
  outset: 4pt,
  [To do...]
)

// Problem function
#let prob-nr = counter("khw:problem")
#let problem = (
  name: auto,
  newpage: auto,
  increment: 1,
  label: none,
  content
) => {
  prob-nr.update(n => n + increment) // Increment counter

  // Page break if requested
  if newpage == auto {
    khw-newpages.display()
  } else if newpage == true {
    pagebreak(weak: true)
  }

  // Line above
  line(length: 100%, stroke: 0.4pt)
  v(-6pt)

  // Problem heading/number and text
  let problem-numbering = (..nums) => {
    if name == auto {
      khw-problemname.display()
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
      supplement: none,
      none
    ) #label],
    content
  )

  // Line below
  v(-6pt)
  line(length: 100%, stroke: 0.4pt)
}


// Parts arguments list
#let problemparts = arguments(
  numbering: (..nums) => [*#numbering("a.i)", ..nums)*],
  tight: false,
)
#let parts = (..args) => {
  enum(
    ..problemparts,
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


// Template
#let khw(
  title: none,
  course: none,
  author: none,
  date: datetime.today(),
  newpages: false,
  problem-name: "Problem",
  doc
) = {
  // Save the value of newpages
  if newpages {
    khw-newpages.update(pagebreak(weak: true))
  }

  // Save the value of problem-name
  khw-problemname.update(problem-name)

  set page(
    paper: "us-letter",
    margin: 1in,
    numbering: "1",
  )

  set text(
    font: "EB Garamond",
    size: 11pt,
    number-type: "lining",
    stylistic-set: 06,
  )

  set par(
    leading: 0.5em,
  )

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
  set enum(..problemparts)
  set pagebreak(weak: true)
  show "%%author%%": author
  show "%%title%%": title
  show "%%date%%": nicedate
  doc
}
