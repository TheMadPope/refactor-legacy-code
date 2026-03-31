# ⚙️ Refactoring Legacy Code ⚙️

This is a companion repo hosting some examples of common refactoring approaches. Please feel free to [reach out to me](mailto:richard@thetransformationgroup.io) with any questions, I love to talk about this stuff!

---

## 🚀 Getting Started

I recommend you start with going through this file, then explore ./force-app/main/default/classes/examples/RefactorExamples.cls. That will give you an overview of easy to apply refactoring strategies without trying to wrap your brain around spaghetti code. From there, the code should lead you into exploring other Classes automatically.

NOTE: If you wish to deploy this project to an org, that org must have at least one RecordType for the Account object, OR change the sObject name in the following methods to reference an object in the org that has at least one RecordType:
* RefactorExamples.doThingsWithRecordTypes_before
* RefactorExamples.doThingsWithRecordTypes_after

---

## 🛠 The Refactor Approach: "Rename, Reduce, Repeat"

The approach for which I advocate is simple: **Rename, Reduce, Repeat**. And avoid complex patterns. And make it readable. And don't get distracted by the big picture - you don't NEED to know what the code is *supposed* to be doing, because you can see what the code *is* doing! In fact, trying to understand the code will often distract you from the important work of refactoring.

### 🗺️ Core Strategies:
* **Rename everything** until it reads like natural language.
* **Invert those IFs** to reduce nesting and cognitive complexity.
* **Instantiate those variables closer to use!** ... because that's wise.
* **Clarify and normalize** conditionals and "feature flags."

### 1. 🦺 Preparation & Safety
Before starting, ensure that **Apex tests are passing**.
* **Rule #1:** Modify the tests, *not* the code. Assume the system is functioning as intended (or as we've grown accustomed to). Remember: we are **NOT** modifying functionality.
* **Baseline Performance:** Use the included `Benchmarker` class to set a baseline for how your org is performing.

> **Pro Tip:** You can use `./dev-tools/scripts/instrument-benchmarker-in-tests` to automatically add Benchmarker calls to your test classes, then use `./dev-tools/scripts/collect-benchmarker-data` to build a CSV of the results.

### 2. 🏷️ Modern Naming Conventions
Naming conventions make a big impact, so you should have one! There's an example naming conventions file in this folder (`./naming-conventions.md`). In ye olden days of Apex we would see variable names that were heavily abbreviated, or that included the variable type in the name (lst, map, etc), but we know better now! Names should be descriptive, avoiding acronyms. It should read as natural language.
* Names should be **descriptive**, avoiding acronyms.
* Code should read as **natural language** (ish).

### 3. 🧪 Atomic Methods & Testing
Enormous legacy methods are really tough to test. By breaking things into smaller methods, they become easier to test, more reliable, and provide a library of code for later reuse.
* **Target:** I aim for **<= 15 lines of code per method**, but I don't go crazy about that, I just see if it makes sense at that atomic level.
* **Avoid the Database:** Wherever possible, avoid hitting the database in your Apex tests. You don't want to age too much while they're running!
* **Avoid Impersonation:** Don't bother with System.runAs(user) unless the specific user will cause a change in your code's behavior!

### 4. 💉 Dependency Injection
This is a lifesaver for testing (resulting in reliable code!) and really easy to implement once you have tiny atomic methods.
* See the `DependencyInjection` class for examples.
* See the `TestFactory` class for examples on how to instantiate test data, including **Custom Metadata records** (yes, really), in your test classes.

---

## 🤖 Working with the Robots

You don't need them! Lots of data shows they actually slow us down and increase churn.
(https://www.jonas.rs/2025/02/09/report-summary-gitclear-ai-code-quality-research-2025.html)
(https://www.gitclear.com/ai_assistant_code_quality_2025_research)
(https://www.devclass.com/ai-ml/2025/02/20/ai-is-eroding-code-quality-states-new-in-depth-report/1626250)

If you feel that you *must* use a robot, keep them on a short leash! Use them for atomic actions, like: *"Please turn thisVariable into a class-level static variable with lazy loading."*

* **Configuration:** I've included an example `copilot-instructions.md` file in the `.github` folder. Modify as you wish! Also be sure to update any references to actual files, so the robot can find what you're talking about.
* **Refinement:** Robots are quite good at helping to refine your configuration files.
* **Verification:** Don't Trust, Also Verify! Always verify what it's imagining the words should be.

---

## 💭 The Philosophy: Velocity through Infrastructure

Keep in mind that ALL of these strategies are intended to accelerate your development.
* **Every line of code is a liability.**
* **If you're writing all new code, you're doing it wrong.**

Once you've built a structured infrastructure of reusable code, you will find that NEW development takes fewer and fewer lines. You'll find yourself typing a method that doesn't exist (yet), like:
`List<Accounts> accountsForZipCode = AccountSelector.getByZipCode('97213');`

When the compiler complains, you can **VERY QUICKLY** go to the `AccountSelector`, write a predictable and simple new method, whip up a super fast test class with positive and negative tests, and you're off to lunch, with not only your problem solved, but you know that NEXT TIME you need accounts by zip code, you can just write those words and **POOF**.

One way to think of these strategies is to get us to write in plain, understandable language. This will rapidly accelerate your development, even if it takes some time to build those skills and/or that codebase.

---

## ❓ FAQ

**Q: Your queries are almost all multi-line, why is that?**\
**A:** I find it much easier to read. Each clause starts a new line, aligned with the previous. If I have an `OR`, I will line that up as well. Check out an example in the `AccountSelector` class.

**Q: Looks like the TestFactory methods... are alphabetical?**\
**A:** *blushes* Yeah, that would be me. I find that trying to keep an Apex (or Javascript) class alphabetical makes it much easier to find what I'm looking for! In this example, I've even included alphabetical **REGION** comments in the `TestFactory` class - including **END REGION** markings (I don't /typically/ include those, just wanted you to see them). I think Regions, and alphabetical method ordering, make things much more tidy. Maybe that makes me old school. BUT ALSO it introduces one more layer of structure so that code that I commit will look SO VERY CLOSE to code that you commit. Having a measure of code homogeneity (sometimes boringly called House Style) will make your code reviews faster, will improve collaboration, and ultimately increase your team's velocity.

**Q: But I don't wanna write a ton of Apex tests! I just want to hit 75% and call it a day!!!**\
**A:** You're better than that! Also, in the current landscape, the robots are VERY GOOD at Apex Tests. And if you've properly structured your code along these guidelines, and included a robot instructions file like `./.github/copilot-instructions.md`, your robot is going to be VERY GOOD at writing atomic Apex tests (in my experience). Obviously, you'll still want to carefully verify what it's imagining the words should be, and make sure that it's following your style properly. Don't Trust, Also Verify! Meanwhile, writing the tests yourself shouldn't take too long, because each of your methods should be only a few lines long! A good rule is **if writing the unit test is complicated, you probably need to refactor and simplify further!**

---

## 📚 Further Reading

* [A lightweight trigger framework](https://github.com/TheMadPope/Lighter-Weight-Trigger-Framework)
* [A handy sfdx project template](https://github.com/TheMadPope/phoenix-project-template)
* [A great approach to constructive PR feedback](https://conventionalcomments.org/)
* [Single Level of Abstraction Principle (SLAP)](https://www.techyourchance.com/single-level-of-abstraction-principle/)
* [Conventional Commits: Strategy for Building Commit Messages](https://www.conventionalcommits.org/en/)
* [Conventional Comments: Strategy for Code Review Feedback](https://conventionalcomments.org/)
* [Pure Unit Testing in Apex](https://www.apexhours.com/pure-unit-testing-in-apex/)
* [Broken Window Theory in Software Development](https://medium.com/@learnstuff.io/broken-window-theory-in-software-development-bef627a1ce99)
* [Peter Naur's "Programming as Theory"](https://pages.cs.wisc.edu/~remzi/Naur.pdf)
