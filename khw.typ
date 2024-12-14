/*
 * khw - Kian's Homework Template for Typst
 *
 * Copyright (C) 2024 Kian Kasad <kian@kasad.com>.
 * This code is made available under the terms of 3-Clause
 * BSD License. See the LICENSE file included in this
 * repository.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

// Function to check argument types {{{1
#let checktype(var, ..types, message) = {
  assert(
    types.pos().contains(type(var)) or
      types.pos().contains(var),
    message: message
  )
}

// Stateful variables used to track configurable options {{{1
#let _khw-problem-prefix = state("_khw-problem-prefix")
#let _khw-parts-numbering = state("_khw-parts-numbering")
#let _khw-newpages = state("_khw-newpages")
#let _khw-align-numbers = state("_khw-align-numbers")

// Problem counter {{{1
#let _khw-problem-counter = counter("_khw-problem-counter")
#let problemnr = _khw-problem-counter  // For exporting

// Document template function {{{1
#let khw(
  title: none,
  course: none,
  author: none,
  date: datetime.today(),
  newpages: false,
  problem-prefix: "Problem",
  parts-numbering: "(a)",
  align-numbers: center + horizon,
  body
) = {
  // Check arguments {{{2
  checktype(title, none, content, str, "Title must be none, content, or string.")
  checktype(course, content, str, none, "Course must be none, content, or string.")
  checktype(author, content, str, none, "Author must be none, content, or string.")
  checktype(date, datetime, none, "Date must be none or datetime.")
  checktype(newpages, bool, "Newpages must be a boolean.")
  checktype(problem-prefix, str, "Problem prefix must a string.")
  checktype(parts-numbering, str, function, "Parts numbering must be a string or function. See numbering().")
  checktype(align-numbers, alignment, "Number alignment must be an alignment.")
  checktype(body, content, "Body must be content.")

  // Document metadata {{{2
  if title != none {
    set document(
      title: title,
      author: author,
      date: date,
    )
  }

  // Set configurable state {{{2
  _khw-problem-prefix.update(problem-prefix)
  _khw-parts-numbering.update(parts-numbering)
  _khw-newpages.update(newpages)
  _khw-align-numbers.update(align-numbers)

  // Format/layout settings {{{2
  set par(justify: true)
  set table(stroke: 0.6pt)
  set math.equation(numbering: "(1)")
  set page(numbering: "1")

  // Title block {{{2
  if title != none {
    align(center, {
      text(weight: "bold", size: 18pt, {
        if course != none {
          course + [ --- ]
        }
        title
      })
      parbreak()
      author
    })
    v(1cm, weak: true)
  }

  // Document body {{{2
  body
}

// To-do placeholder {{{1
#let todo = text(stroke: red, fill: red, size: 18pt)[TODO]

// Problem function {{{1
#let problem(
  number: auto,
  points: none,
  newpage: auto,
  align-number: auto,
  outlined: true,
  _content
) = context {
  // Check arguments
  checktype(number, auto, str, content, "Number must be auto, string, or content.")
  checktype(points, none, str, int, float, content, "Points must be string, integer, float, or content.")
  checktype(newpage, auto, bool, "Newpage must be auto or boolean.")
  checktype(align-number, auto, alignment, "Align-number must be auto or alignment.")
  checktype(outlined, bool, "Outlined must be a boolean.")
  checktype(_content, content, "Problem content must be content.")

  let num = number
  if number == auto {
    _khw-problem-counter.step()
    num = context _khw-problem-counter.display()
  }

  if (newpage == auto and _khw-newpages.get() == true) or (newpage == true) {
    pagebreak()
  }
  v(24pt, weak: true)
  block(breakable: false, {
    line(length: 100%)
    if outlined {
      show heading: it => none
      heading(numbering: none)[#_khw-problem-prefix.get() #num]
    }
    grid(
      columns: (auto, 1fr),
      gutter: 12pt,
      align: top + left,
      text(size: 16pt, weight: "bold", _khw-problem-prefix.get()),
      grid.cell(
        rowspan: 2,
        {
          if points != none {
            [_(#points points)_]
            h(4pt)
          }
          set enum(numbering: "(a)", tight: true)
          _content
        }
      ),
      grid.cell(
        align: if align-number == auto {
          _khw-align-numbers.get()
        } else {
          align-number
        },
        text(size: 48pt, weight: "black", num)
      ),
    )
    line(length: 100%)
  })
}

// Parts function {{{1
#let parts(
  breakable: false,
  ..args
) = context {
  checktype(breakable, bool, "Breakable must be boolean.")
  enum(
    numbering: _khw-parts-numbering.get(),
    tight: false,
    ..args.named(),
    ..args.pos().map(it => {
      set enum(numbering: "i.")
      block(breakable: breakable, width: 100%, it)
    })
  )
}

// Equation without number {{{1
#let nonumeq = math.equation.with(numbering: none)

// Boxed function {{{1
#let boxed = box.with(
  stroke: 0.4pt + black,
  outset: 3pt
)

// Pseudocode blocks {{{1
#let kalgo = (..args, body) => {
  import "@preview/algo:0.3.3": algo
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

// 1}}}

// vim: set formatoptions+=n textwidth=59 foldmethod=marker foldmarker={{{,}}}:
