# Boundary

Building a big application in Ruby requires separation business domain logic from the MVC to a separate layer, usually called `Services` or `Domains`. Unfortunately, these are no standards of organazing this layer, so every project reinvent their own wheels.

`Boundary` is a Ruby gem that provides a set of tools to help building robust and scalable applications, by enforcing developers to follow the architectural rules.

The gem stands of principles such as:

- **Enforcing boundary contexts:** provides a flexible framework that forces you to implement code namespaces with public interface and truly hidden implementation. This prevents creating big ball of mug, where different parts of the code call each other in a random way
- **Configuration management:** makes it easy to manage configuration settings for the application, considering your target project's best practices, so as to keep the codebase style consistent across the whole modules.
- **"No Big Bang" concept:** allows using the gem for both new and existing projects by making a gentle step-by-step refactoring.
- **"Least Surprise" principle** leads the gem, which means avoiding metaprogramming as much as possible, and using direct references for classes as methods. Direct references also improve the navigation, when it comes to your favorite IDE.
- **Framework-agnostic principle:** in particular means the gem can be applied in RubyOnRails, Hanami, and other Ruby frameworks. However, there is one limitation: Gem relies on `Zeitwerk` loader behaviour, so the framework should work with it (other loaders might not work in 100% cases, so you should check it by yourself).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'boundary', source: 'https://github.com/evgeny-danilov/boundary'
```

or install it directly:

```bash
gem install boundary --source https://github.com/evgeny-danilov/boundary
```

## Usage

```ruby
# config/initializers/boundary.rb
Boundary.initialize do |config|
  config.defined_namespaces = ['MyNamespace::Facade']
end
```

```ruby
# Somewhere in the service layer
module MyNamespace
  # public interface:
  class Facade
    include Boundary::Facade

    has_use_case :do_something, DoSomething # in order to generate less magic we explicitly refer to a class
    # Note: Class `DoSomething` should respond to `call` class method
  end
  
  # hidden implementation:
  class DoSomething
    def self.call(params:)
      new(params: params).call
    end
    # or simply use a build-in mixin, which adds `self.call` method automatically
    include Boundary::Mixins::Callable
    
    def initialize(params:)
      # some initializations
    end
    
    def call
      "executable code"
    end
  end
end
```

After that you can use the public interface outside:
```ruby
MyNamespace::Facade.do_something(params)
```

while accessing any inner class will cause an error:

```ruby
MyNamespace::DoSomething.call(params) 
# => NameError: private constant MyNamespace::DoSomething referenced

MyNamespace::const_get(:DoSomething).call(params) 
# => NameError: private constant MyNamespace::DoSomething referenced
```
These restrictions are configurable. However, we recommend following the default behaviour.

## Configuration

Example:
```ruby
# config/initialize/boundary.rb
# TODO: describe, that it should be included in the `preload` section or something...(to be checked in Rails and Hanami)
Boundary.initialize do |config|
  config.const_get_receive_only_public_constants = true
  config.defined_namespaces = ['MyNamespace::Facade']
end
```

TODO: explain all config settings

## Example application

Check the [test_app](test_app) folder as an example of using `Boundary` in the RubyOnRails application.

## How does it work under the hood

First of all it is worth to remind, that in Ruby all classes and modules are constants. For example, in `MyNamespace::Action::Call` the class `Action` is a first-tier constant under the `MyNamespace` module.

At the initialization stage we define all namespaces, needed to be isolated. Under the hood `Boundary` gem **preload them all** and marks inner first-tier constants of these namespaces as private, by using Ruby's in-build function `private_constant(const_name)`, and preventing `const_get` for private constants. `Facade` becomes a single public class, available outside the namespace.

Also in the init stage `Boundary` gem adds to the `MyNamespace::Facade` all class methods that have been defined through DSL instruction `has_use_case`, `has_constract` and others, so it can be used like `MyNamespace::Facade.do_smoething(...)`. However, it also means, all inner classes and modules will be eagerly loaded (pls, open an issue, if it somehow does not fit your needs, as it's very easy to fix).

## Most common issues with legacy apps
TODO: move to another page

1. When there are some classes or modules, defined outside the bounded namespace.

This is a common situation in legacy apps, when modules are defined in different parts of the code. For example, you might have a namespace `Payments` inside the folder `app/services/`, while the related ActiveRecord model is placed in `app/models/payments/payment.rb`. In this case gem will mark `Payments::Payment` ActiveRecord model as private, available only inside the namespace.

To avoid this situation you can move all related modules into a single place of the code, and provide a public interface to access them from outside. Another solution would be to turn off the setting `const_get_receive_only_public_constants` and use `Peyments.const_get(:Payment)` notation, but we would not recommend doing it, as it actually breaks the concept of the bounded contexts (it is probably worth doing only on a temporary base, during the refactoring).

In fact, you can use this behaviour as a benefit, to catch all related modules across the code, to join them together under a single folder.

3. The method `Boundary.initialize` eagerly loads namespaces with all classes, defined in their facades.

If, for some reason, the behaviour is not suitable for you - create an issue, and we'll try to introduce a new config
TODO: check if we can do it right now.

4. If you are working with different loaders, other than `Zeitwerk`, they should be able to provide the list of constants for a module or class, before an actual loading of these classes.

5. Do you know more? That's great! Feel free to open the issue.

## Philosophy

**The human brain is always about find the easiest way to do things. So, the general idea is to organize code in that way, that following good design will be the simplest way among others.**

Ruby is an incredibly flexible tool, which, however, provides too much freedom for developers. It is not a problem for small and middle projects with simply CRUD operations. However, when the project grows, it becomes harder to maintain the complexity, as the code turns into a big ball of mugs, where different parts of the code call each other in a random way, generating cyclic dependencies and a lot of legacy. This significantly increases the cost of further development.

But what if we get a set of strict rules that enforce us to follow the best practices of designing domain logic? The `Boundary` gem is here for that!

**Here are some of benefits of usage the gem:**
- a strict way to introduce code namespaces with truly encapsulation
- build-in restrictions to hide the implementation under the public interface
- flexible configuration allows to set-up our own rules of designing the code.
- for new project it provides a great tool to follow best code-design practices at the very beginning
- for existing projects it does not generate a big-bang, so as to gently refactor the code step-by-step

For more information about the philosophy behind the tool check the article: TODO

## Alternatives

In Ruby community there are various approach to enforce good code organization:
- building "best practices" guides and rely on engineering culture (does not work well in big teams)
- using linters, such as Rubocop (quite hard to maintain, while engineers still can avoid restrictions by disabling rules locally)
- `Rails Engines` or gems, such as [Facade](https://github.com/djberg96/facade) or [Caze](https://github.com/magnetis/caze) (do not provide true isolation, but only another level of abstractions)
- Gem [https://github.com/shioyama/im](https://github.com/shioyama/im) (looks promising, but not yet ready for production)
- **Ractors** model, which created for concurrent tasks, but can potentially be also used to implement isolated namespaces (also looks promising, but still in the experimental phase)

## TODO LIST

1. Think about separating use cases by roles (for ex: `as_admin { has_use_case :do_something }`
2. Naming convention: namespace is a noun (as a domain area), while use case is a verb (as an action)) 
2. Check possible edge cases with private constants, for example when we reference to `NyNamespace::Errors` or something
2. Publish to [rubygems.org](https://rubygems.org), in order to be able to install directly as 'gem install boundary'
3. Async calls through the facade?
4. Check compatibility with old Ruby versions (probably, it will requite to get rid of dry-configurable)
5. `has_use_case` and others should receive only classes (or lambdas as well, if appropriate settings are configured)
6. Try to move to dry.rb libraries
7. Add installer command so as to generate an initializer with explained configs in `config/initializers/` folder

## Contribution

Help is welcome and much appreciated, whether you are an experienced developer or just looking for sending your first pull request or bug report.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CONTIOBUTIONS.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.md).
