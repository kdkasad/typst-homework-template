#import "khw.typ": khw, problem as _problem, parts

#set document(
  title: [Manual for Kian's Homework Template],
  author: "Kian Kasad",
  date: datetime.today(),
)

// Show content with khw() so the necessary setup happens
#show: khw

// Override the problem() function to disable outlining
#let problem = _problem.with(outlined: false)

// Title page {{{1
#grid(
  columns: (1fr,),
  rows: (1fr, 1fr, 1fr, 1fr),
  align: center,
  [], [
    #line(length: 100%)
    #text(size: 24pt, weight: "bold")[Kian's Homework Template]

    #link("https://github.com/kdkasad/typst-homework-template")

    Kian Kasad

    #datetime.today().display()
    #line(length: 100%)
    <cover>
   ]
)
#pagebreak()
// 1}}}

// Layout/format settings {{{1
#set par(justify: true)
#set page(numbering: "1")
#set heading(numbering: (..nums) => numbering("1.1", ..nums) + h(1em))
#set raw(lang: "typc")
// 1}}}

// Function for typesetting argument list items {{{1
#let arg(name, types, description) = {
  set terms(indent: 1em)
  set raw(lang: none)
  let body = {
    show raw.where(lang: none): it => text(purple, it)
    [(]
    types.map(it => raw(it)).join([ | ])
    [)]
    h(0.5em)
    description
  }
  terms.item(name, body)
}
// 1}}}

// Function to render examples {{{1
#let example(code, caption, render: true) = {
  figure(
    kind: "example",
    supplement: [Example],
    caption: caption,
    table(
      columns: (auto, 1fr,),
      align: left + horizon,
      fill: (x, y) => if x == 0 { gray.lighten(50%) },
      inset: 8pt,
      rotate(-90deg, reflow: true)[Markup],
      code,
      ..if render {
        (
          rotate(-90deg, reflow: true)[Result],
          eval(
            // Remove imports so our custom problem() doesn't
            // get shadowed.
            code.text.replace(regex("#import\s+.*\n"), ""),
            mode: "markup",
            scope: (
              parts: parts,
              problem: problem,
            )
          )
        )
      } else { () },
    ) // table
  ) // figure
}
// 1}}}

// Table of Contents
#outline()
// List of examples
#outline(
  title: [Examples],
  target: figure.where(kind: "example")
)
#pagebreak()

= Introduction

This project is a document template I created for homework
assignments. It is licensed under the BSD-3-Clause license and is
available at the URL on #link(<cover>)[the cover page].

= Using the template
To use the template, download the file `khw.typ` from this
project's repository and place it in your project/document's
working directory. If your project is a Git repository, you
can use a Git submodule to include the template repository
within your own.

== Document setup
To set up your document, import the `khw()` function and apply
it to all content using a show rule:

#example(render: false,
```typst
#import "khw.typ": khw
#show: khw.with(
  title: [My Homework Assignment],
  author: "Your Name",
)
```
)[Document setup code.]

The `title` and `author` fields are used to print a title
block on the first page, as well as to set the document's
metadata using ```typc document()```.

The `khw()` function supports the following optional parameters:

#arg(`title`, ("content", "str", "none"))[
  Document title. Defaults to `none`. If `none`, no title
  block is printed and no document metadata is set.
]

#arg(`author`, ("content", "str", "none"))[
  Document author. Defaults to `none`.
]

#arg(`date`, ("datetime",))[
  Document creation date.
  Defaults to ```typc datetime.today()```.
]

The following options do not take effect immediately, but are
used to set default options for the ```typc problem()``` and
```typc parts()``` functions provided by this template.

#arg(`newpages`, ("bool",))[
  Whether to start each problem on a new page.
  Defaults to false.
]

#arg(`problem-prefix`, ("str",))[
  The word to place before each problem
  number. Defaults to "Problem".
]

#arg(`align-numbers`, ("alignment",))[
  How to align problem numbers
  within the problem header.
  Default is ```typc center + horizon```.
]

#arg(`parts-numbering`, ("str", "function"))[
  Numbering to use for
  parts of a problem. Takes a value which can be used as the
  argument to ```typc numbering()```.
]

#pagebreak()
== Typesetting problems
Use the `problem()` function to typeset a problem. The
function takes a non-optional content argument which can be
used to specify the problem prompt/question.

#example(
```typ
#import "khw.typ": problem
#problem[
  #lorem(25)
]
```
)[Typesetting a problem using `problem()`.]

If #link(<problem-arg-outlined>)[the `outlined` parameter] is
not disabled, a first-level heading is created for each
problem. If you need headings within problems, you should
start with second-level headings.
This also means that problems will appear in the table of
contents (if your document has one) and in the table of
contents embedded in the PDF's metadata (a.k.a. bookmarks).

The `problem()` function takes the following optional
arguments:

#arg(`number`, ("auto", "str", "content"))[
  Specifies the number of the problem. When `auto`, problems
  are automatically numbered sequentially starting from 1.
  Defaults to `auto`.
]

#arg(`points`, ("none", "str", "int", "float", "content"))[
  Specifies the point value of the problem. Defaults to
  `none`. See @points.

  #example(
  ```typ
  #problem(points: 5)[
    #lorem(25)
  ]
  ```
  )[Problem with points value specified.] <points>
]

#arg(`newpage`, ("auto", "bool"))[
  Whether to insert a page break before the problem header. If
  `auto`, the value of the ```typc newpages``` argument to the
  ```typc khw()``` function is used. Defaults to `auto`.
]

#arg(`align-number`, ("auto", "alignment"))[
  How to align the problem number. When `auto`, the value of
  the ```typc align-numbers``` argument to the ```typc khw()```
  function is used.

  Passing a value of ```typc center + top``` will center the
  problem number right below the problem prefix text, so that
  it always appears consistent no matter the height of the
  problem prompts.
]

#arg(`outlined`, ("bool",))[
  Whether this problem shows up in the outline. If `true`, an
  invisible ```typc heading()``` is created for this problem,
  making it act like a regular heading.
  Defaults to `true`.
  <problem-arg-outlined>
]

== Typesetting multi-part problems
For problems with multiple parts, there are two places you
might want to typeset the parts: in the prompt and in the
response/solution.

=== In the prompt
The content which makes up the prompt is displayed with
a `set` rule that numbers regular lists using the format
`"(a)"`. You can create a regular numbered list in the prompt
to typeset a multi-part prompt. See @prompt-parts.

#example(
```typ
#problem(points: 10)[
  Explain how virtual memory speeds up the following operations:
  + Allocating zero-initialized pages.
  + Spawning child processes.
]
```
)[Multi-part problem prompt.] <prompt-parts>

=== In the response

Since the solution is more likely to include regular numbered
lists, I decided not to just use a `set` rule and to instead
make a function for typesetting parts. This also makes it
quite easy to split up multi-part problems into separate
source files.

Use the `parts()` function to typeset multiple parts in the
solution.
See @parts-function.

#example(
```typ
#parts[
  Virtual memory allows for copy-on-write behavior, making
  page allocation faster.
][
  Only the page table needs to be copied when spawning a child
  process, rather than the entire space of mapped memory.
]
```
)[Multi-part problem response.] <parts-function>

Sub-parts can be typeset using a normal numbered list and will
be numbered with lowercase Roman numerals. See @subparts.

#example(
```typ
#parts[
  #lorem(5)
  + #lorem(5)
  + #lorem(5)
]
```
)[Solution with parts and sub-parts.] <subparts>

// vim: foldmethod=marker foldmarker={{{,}}} sw=2 ts=2 et tw=62
