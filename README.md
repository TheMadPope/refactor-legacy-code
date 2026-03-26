# Refactoring Legacy Code: Examples

This is a companion repo hosting some examples of common refactoring approaches. Please feel free to [reach out to me](mailto:richard@thetransformationgroup.io) with any questions, I love to talk about this stuff!

# Reading this repo

I recommend you start with going through this file, then explore ./force-app/main/default/classes/examples/RefactorExamples.cls. That will give you an overview of easy to apply refactoring strategies without trying to wrap your brain around spaghetti code. From there, the code should lead you into exploring other Classes automatically.

# Refactor Approach

The approach for which I advocate is simple: Rename, Reduce, Repeat. And avoid complex patterns. And make it readable. And don't get distracted by the big picture - you don't NEED to know what the code is /supposed/ to be doing, because you can see what the code /is/ doing! In fact, trying to understand the code will often distract you from the important work of refactoring. Instantiate those variables closer to use! Invert those IFs! Clarify and normalize conditionals and 'feature flags'! And and and ... ! (this paragraph should be refactored.)

Before starting a refactoring project, ensure that Apex tests are passing (modify the tests, not the code - assume that the system is functioning as intended - or as we've grown accustomed to. Remember that as part of refactoring, we are NOT modifying functionality). Then, it can be good to use a utility like the included Benchmarker class to set a baseline for how your org is performing. I'm also including a script to collect Benchmarker data in ./dev-tools/scripts/collect_benchmarker_data. You can manually add the Benchmarker to your tests (a la ./force-app/main/default/tests/RecordTypeServiceTest.cls) or ask your robot to write a script to add it to all your existing tests. I recommend telling it to add Benchmarker.start() just after the Test.startTest() invocation, and Benchmarker.mark(methodName) just after the Test.stopTest() invocation. If the method doesn't use Test.startTest(), just put the Benchmarker.start() at the start of the test method, and Benchmarker.mark(methodName) at the end of the test method. It won't get you a perfect view of what your code is doing, but it will give you a before and after to see how far you've come!

I don't recommend introducing complex frameworks as they tend to increase bloat and cruft, and often have too many features. They can also add complexity for both processing and comprehension. Only include what is needed! The included TriggerHandler is an example of a thin framework that gives you just enough to be useful and encourage good Trigger patterns without overburdening the codebase with too many bells and/or whistles.

Naming conventions make a big impact, so there's an example naming conventions file in this folder. In ye olden days of Apex we would see variable names that were heavily abbreviated, or that included the variable type in the name (lst, map, etc), but we know better now! Names should be descriptive, avoiding acronyms. It should read as natural language.

Often enormous legacy methods are really tough to test. By breaking things into smaller methods they're much easier to test, making them more reliable, and providing you with a reusable library of code for later reuse. (Re: Small methods, my target is <=15 lines of code per method - but I don't go crazy about that, I just see if it makes sense at that atomic level)

Dependency injection is a lifesaver for testing (resulting in reliable code!) and really easy to implement when you have tiny atomic methods. In this repo you'll find a class called DependencyInjection that shows a few examples. There's also a TestFactory class that shows you how to instantiate Custom Metadata records (yes, really) in your test classes.

If you feel that you *must* use a robot, keep them on a short leash! Use them for atomic actions, like "Please turn thisVariable into a class-level static variable with lazy loading". I've included an example copilot-instructions.md file in the .github folder. Modify as you wish! Also, the robots tend to be good at helping to refine your copilot-instructions.md file (or whatever flavor of robot config file you use).

Keep in mind that ALL of these strategies are intended to accelerate your development.
/Every line of code is a liability/
/If you're writing all new code, you're doing it wrong/
Once you've built out a structured, well, infrastructure of reusable code, you will find that NEW development takes fewer and fewer lines. You'll find yourself typing a method that doesn't exist (yet), like: List<Accounts> accountsForZipCode = AccountSelector.getByZipCode('97213')... Then when the compiler comes back to complain that the method doesn't exist, you can VERY QUICKLY go to the AccountSelector, write a VERY predictable and simple new method, whip up a super fast test class with positive and negative tests, and you're off to lunch with not only your problem solved, but you know that NEXT TIME you need accounts by zip code, you can just write those words and POOF.

One way to think of these strategies is to get us to write in plain, understandable language. This will rapidly accelerate your development, even if it takes some time to build those skills and/or that codebase.

# Errata

**Q**: Your queries are almost all multi-line, why is that?\
**A**: I find it much easier to read. Each clause starts a new line, aligned with the previous. If I have an OR, I will line that up so that it is easier to read, as well.
Check out an example in the AccountSelector class.

**Q**: Looks like the TestFactory methods... are alphabetical?\
**A**: *blushes* Yeah, that would be me. I find that trying to keep an Apex (or Javascript) class alphabetical makes it much easier to find what I'm looking for! In this example, I've even included alphabetical REGION comments in the TestFactory class - including END REGION markings (I don't typically include those, just wanted you to see them). I think Regions, and alphabetical method ordering, make things much more tidy. Maybe that makes me old school. BUT ALSO it introduces one more layer of structure so that code that I commit will look SO VERY CLOSE to code that you commit. Having a measure of code homogeneity (sometimes boringly called House Style) will make your code reviews faster, will improve collaboration, and ultimately increase your team's velocity.

**Q**: But I don't wanna write a ton of Apex tests for my code! I just want to hit 75% and call it a day!!!\
**A**: You're better than that! Also, in the current landscape, the robots are VERY GOOD at Apex Tests. And if you've properly structured your code along these guidelines, and included a robot instructions file like ./.github/copilot-instructions.md, your robot is going to be VERY GOOD at writing atomic Apex tests (in my experience). Obviously, you'll still want to carefully verify what it's imagining the words should be, and make sure that it's following your style properly. Don't Trust, Also Verify!

# Further Reading

* A lightweight trigger framework [here](https://github.com/TheMadPope/Lighter-Weight-Trigger-Framework)
* A handy sfdx project template [here](https://github.com/TheMadPope/phoenix-project-template)
