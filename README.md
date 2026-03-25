# Refactoring Legacy Code: Examples

This is a companion repo hosting some examples of common refactoring approaches. Please feel free to [reach out to me](mailto:richard@thetransformationgroup.io) with any questions, I love to talk about this stuff!

# Refactor Approach

The approach for which I advocate is simple: Rename, Reduce, Repeat. And avoid complex patterns. And make it readable. And don't get distracted by the big picture - you don't NEED to know what the code is /supposed/ to be doing, because you can see what the code /is/ doing! In fact, trying to understand the code will often distract you from the important work of refactoring. Instantiate those variables closer to use! Invert those IFs! Clarify and normalize conditionals and 'feature flags'! And and and ... ! (this paragraph should be refactored.)

I don't recommend introducing complex frameworks as they tend to increase bloat and cruft, and often have too many features. They can also add complexity for both processing and comprehension. Only include what is needed! The included TriggerHandler is an example of a thin framework that gives you just enough to be useful and encourage good Trigger patterns without overburdening the codebase with too many bells and/or whistles.

Naming conventions make a big impact, so there's an example naming conventions file in this folder. In ye olden days of Apex we would see variable names that were heavily abbreviated, or that included the variable type in the name (lst, map, etc), but we know better now! Names should be descriptive, avoiding acronyms. It should read as natural language.

Often enormous legacy methods are really tough to test. By breaking things into smaller methods they're much easier to test, making them more reliable, and providing you with a reusable library of code for later reuse. (Re: Small methods, my target is <=15 lines of code per method - but I don't go crazy about that, I just see if it makes sense at that atomic level)

Dependency injection is a lifesaver for testing (resulting in reliable code!) and really easy to implement when you have tiny atomic methods. In this repo you'll find a class called DependencyInjection that shows a few examples. There's also a TestFactory class that shows you how to instantiate Custom Metadata records (yes, really) in your test classes.

If you feel that you *must* use a robot, keep them on a short leash! Use them for atomic actions, like "Please turn thisVariable into a class-level static variable with lazy loading". I've included an example copilot-instructions.md file in the .github folder. Modify as you wish! Also, the robots tend to be good at helping to refine your copilot-instructions.md file (or whatever flavor of robot config file you use).
