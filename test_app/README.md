# Test Rails application 

There is a example of how to use `Boundary` gem in a Rails application.

It has the folder `domains/payments`, which is supposed to be isolated from the rest of the functionality.

In fact, the folder can we a Rails engine, a Gem, or just a container of Ruby classes - for the `Boundary` gem it doesn't matter.

As long as the code is wrapped in the same Ruby module, `Boundary` gem will hide the implementation and provide a public interface.
