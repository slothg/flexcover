**FLEX 4 NOW SUPPORTED**:
Flexcover 0.90, which features support for Flex 4.0 & AIR 2.0 has been posted in the downloads section.

Many thanks to Brian Stanek, whose hard work helped make this release possible!

**NEW AND NOTEWORTHY**: Paul Barnes-Hoggett has implemented headless coverage recording with EMMA-style report output using a custom coverage agent -- see http://eyefodder.com/ for details.

If you are having problems, check out the FlexcoverHints page.  You can also look at the Flexcover Discussion Group (see sidebar for link), and it's a good place to post a question.

This project provides code coverage instrumentation, data collection and reporting tools for Adobe Flex and AIR applications.

Flexcover is a code coverage tool for Flex, AIR and AS3.  It incorporates a modified version of the AS3 compiler which inserts extra function calls in the code within the SWF or SWC output file. At runtime, these function calls send information on the application's
code coverage to a separate tool;  The modified compiler also emits a separate "coverage metadata" file that describes all the possible packages, classes, functions, code blocks and lines in the code, as well as the names of the associated source code files.

Flexcover now computes both line coverage and branch coverage.  In branch coverage conditional code paths rather than lines are counted.  Many developers feel that branch coverage is a much more accurate measure of coverage, and it is able to detect coverage issues that occur within a single line of code such as compound conditionals with || and &&, or conditional expressions using the ?: operator.

The corresponding SDK modifications can be found in the [flexcover-sdk](http://code.google.com/p/flexcover-sdk/) project on Google Code.

Here's a screenshot:

![http://flexcover.googlecode.com/svn/trunk/doc/images/screenshot.png](http://flexcover.googlecode.com/svn/trunk/doc/images/screenshot.png)

Flexcover is a joint effort with Alex Uhlmann of Adobe Consulting, who has been working on a related set of ideas.
