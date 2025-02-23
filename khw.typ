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

  // Page header {{{2
  set page(
    header-ascent: 50%,
    header: context {
      set text(10pt)
      let pagenum = counter(page).get().first()
      if pagenum != 1 {
        if course != none {
          if type(course) == str {
            course.replace(regex("(:\s+|\s+-+\s+).*$"), "")
          } else {
            course
          }
          [ --- ]
        }
        title
        h(1fr)
        author
      }
    }
  )

  // Title block {{{2
  if title != none {
    align(center, {
      text(18pt, weight: "bold", title)
      linebreak()
      text(12pt, course)
      linebreak()
      text(12pt, author)
    })
    v(1cm, weak: true)
  }

  // Document body {{{2
  body
}

// To-do placeholder {{{1
#let todo = text(red, size: 18pt)[[To do]]

// Problem function {{{1
#let problem(
  prefix: auto,
  number: auto,
  points: none,
  newpage: auto,
  align-number: auto,
  outlined: true,
  _content
) = context {
  // Check arguments
  checktype(prefix, auto, str, content, none, "Prefix must be auto, string, content, or none.")
  checktype(number, auto, str, content, "Number must be auto, string, or content.")
  checktype(points, none, str, int, float, content, "Points must be string, integer, float, or content.")
  checktype(newpage, auto, bool, "Newpage must be auto or boolean.")
  checktype(align-number, auto, alignment, "Align-number must be auto or alignment.")
  checktype(outlined, bool, "Outlined must be a boolean.")
  checktype(_content, content, "Problem content must be content.")

  let num = number
  if number == auto {
    _khw-problem-counter.step()
  }

  if (newpage == auto and _khw-newpages.get() == true) or (newpage == true) {
    pagebreak()
  }
  v(24pt, weak: true)
  [#block(breakable: false, {
    line(length: 100%)
    if outlined {
      show heading: it => none
      context heading(numbering: none, {
        if prefix == auto { _khw-problem-prefix.get() } else { prefix }
        [ ]
        if number == auto {
          _khw-problem-counter.display()
        } else {
          number
        }
      })
    }
    grid(
      columns: (auto, 1fr),
      gutter: 12pt,
      align: top + left,
      grid.cell(
        text(size: 16pt, weight: "bold", [
          #{ if prefix == auto { _khw-problem-prefix.get() } else { prefix } }
          <khw-problem-prefix>
        ])
      ),
      grid.cell(
        rowspan: 2,
        [
          #{
            if points != none {
              [_(#points points)_ <khw-problem-points>]
              h(4pt)
            }
            set enum(numbering: "(a)", tight: true)
            set math.equation(numbering: none)
            _content
          } <khw-problem-prompt>
        ]
      ),
      context grid.cell(
        align: if align-number == auto {
          _khw-align-numbers.get()
        } else {
          align-number
        },
        text(
          size: 48pt,
          weight: "black",
          [
            #if number == auto {
              _khw-problem-counter.display()
            } else {
              number
            }
            <khw-problem-number>
          ]
        )
      )
    )
    line(length: 100%)
  }) <khw-problem-block>]
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
    ..args.pos().map(it => [
      #set enum(numbering: "i.")
      #block(breakable: breakable, width: 100%, it)
      <khw-part>
    ])
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

// Dashed problem divider {{{1
#let divider = line(length: 100%, stroke: (thickness: 0.5pt, dash: "dashed"))

// 1}}}

// vim: set formatoptions+=n textwidth=59 foldmethod=marker foldmarker={{{,}}}:
