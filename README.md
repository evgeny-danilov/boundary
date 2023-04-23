# Boundary

`Boundary` is a Ruby gem that provides a set of tools to help building robust and scalable applications. It includes features such as:

- **Enforcing boundary contexts:** Gem provides a flexible framework that allows you to implement code namespaces with public interface and truly hidden implementation.
- **Configuration management:** Gem makes it easy to manage configuration settings for the application depends on project's best practices, so as to keep the codebase style consistent across the whole project.
- **"No Big Bang" concept:** allows using the gem for both new and existing projects, to make a gentle refactoring step-by-step.

The gem tends to be **framework-agnostic**, which in particular means it can be applied in RubyOnRails, Hanami, and some other Ruby frameworks. However, there is one limitation - `Boundary` relies on `Zeitwerk` loader behaviour, so the framework should support it (other loaders might work not in 100% cases, so you should check it by yourself).

Gem `Boundary` was built according to the principle of **"Least Surprise"**, which means avoiding metaprogramming as much as possible, and use direct refers for classes as methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'boundary'
```

or install it directly:

```ruby
gem install boundary
```

## Usage

Imagine you have a namespace to be isolated from other parts of the code:

```ruby
module MyNamespace
  # public interface:
  class Facade
    include Boundary::Facade

    has_use_case :do_something, DoSomething # in order to generale less magic we refer to a class directly
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

Note that naming `Facade` is configurable, and you can use your own naming across the project.
Check the section "Configuration" for details.

#### Accessing any inner class will cause an error

```ruby
MyNamespace::DoSomething.call(params) 
# => NameError: private constant MyNamespace::DoSomething referenced

MyNamespace::const_get(:DoSomething).call(params) 
# => NameError: private constant MyNamespace::DoSomething referenced
```
While these restrictions are configurable, we recommend following the default behaviour.

## Configuration

Example:
```ruby
# config/initialize/boundary.rb
# TODO: describe, that it should be included in the `preload` section or something...(to be checked in Rails and Hanami)
Boundary.initialize do |config|
  config.const_get_receive_only_public_constants = true
  config.defined_namespaces = [MyNamespace::Facade]
end
```

> **Warning**
> It is important to include `Boundary.initialize` into a reloadable part of your application! Otherwise, all the constants will be public after reloading.

Once you have initialized it, configuration will be immutable.

TODO: explain all config settings

## How does it work under the hood

First of all it worth to remind, that in Ruby all classes and modules are constants. For examples, in `MyNamespace::Action::Call` the class `Action` is a first-tier constant under the `MyNamespace` module.

As you might notice in the previous section, we define and **preload** all namespaces at the initialization stage. Under the hood `Boundary` gem marks inner first-tier constants of these namespaces as private, by using Ruby's in-build function `private_constant(const_name)`, and preventing `const_get` for private constants. `Facade` becomes a single public class, available outside the namespace.

Also in the init stage, `Boundary` gem adds to the `MyNamespace::Facade` all class methods that have being defined thought DSL instruction `has_use_case`, `has_constract` and other. It literally means, all inner classes and modules will be eagerly loaded (pls, open an issue, if it somehow does not fit your needs).

## Most common issues with legacy apps
TODO: move to another page

1. When there are some classes or modules, defined outside the bounded namespace.

This is a common situation in legacy apps, when modules defined in different parts of the code. For examples, you have a namespace `Payments` inside the folder `app/domains/`, while related AR model is placed in `app/models/payments/payment.rb`. In this case gem will mark `Payments::Payment` model as private, available only inside the namespace.

To avoid this situation you can move all related modules into a single place of the code, and provide a public interface to access them from outside. Another solution would be to turn off the setting `const_get_receive_only_public_constants` and use `Peyments.const_get(:Payment)` notation, but we would not recommend doing it, as it actually breaks the concept of the bounded contexts (it is probably worth doing only on a temporary base, during the refactoring).

So, actually, you can use this behaviour to catch all related modules across the code, to join them together.

3. The method `Boundary.initialize` eagerly loads namespaces with all classes, defined in their facades.

If, for some reason, the behaviour is not suitable for you - create an issue, and we'll try to introduce a new config
TODO: check if we can do it right now.

4. If you are working with different loaders, other then `Zeitwerk`, they should be able to provide the list of constants for a module or class, before an actual loading of these classes.

5. Do you know more? That's great! Feel free to open the issue.

## Philosophy

Ruby is an incredibly flexible tool, which, however, provides too much freedom for developers. It is not a problem for small and middle projects with simply CRUD operations. However, when the project grows, is becomes harder to maintain the complexity, as the code turns on into a big ball of mug, where different parts of the code call each other in a random way, generating cyclic dependencies and a lot of legacy. This significantly increases the cost of further development.

But what if we get a set of strict rules that enforce us to follow the best practices of designing domain logic? The `Boundary` gem is here for that!

**Here are some of benefits of usage the gem:**
- a strict way to introduce code namespaces with truly encapsulation
- build-in restrictions to hide the implementation under the public interface
- flexible configuration allows to set-up our own rules of designing the code.
- for new project it provides a great tool to follow best code-design practices at the very beginning
- for outdated projects it does not generate a big-bang, so we to gently refactor the code step-by-step

For more information about the philosophy behind the tool check the article: TODO

## Alternatives

In Ruby community there are various approach to solve the same problems:
- building "best practices" guides and rely on engineering culture (does not work well in big teams)
- using linters, such as Rubocop (quite hard to maintain, while engineers still can avoid restrictions by disabling rules locally)
- `Rails Engines` or gems, such as [Facade](https://github.com/djberg96/facade) or [Caze](https://github.com/magnetis/caze) (do not provide true isolation, but only another level of abstractions)
- Gem [https://github.com/shioyama/im](https://github.com/shioyama/im) (looks promising, but not yet ready for production)
- **Ractors** model, which created for concurrent tasks, but can be also used to implement isolated namespaces (also looks promising, but still in the experimental phase)

_** Hopefully, Ractors will become a solid part of the Ruby language, and step-by-step concur our projects [crossfingers].

## TODO LIST

1. Check how Zeitwerk works with namespaces
2. Check if we can freeze Facade class without drawbacks
3. Extract it in a Gem
4. Check the EPAM open source contributions program
5. What if we call model Namespace::Model outside the namespace, while facade is not loaded yet? Shall we load all facades at the beginning?
6. Async calls through the facade?
7. Check compatability with old Ruby versions (probably, it will requite to get rid of dry-configurable)
8. https://bugs.ruby-lang.org/issues/14982
9. has_use_case and others should receive only classes
10. Try to move to dry.rb libraries
11. Create a PR to add the feature `config.finalize!(freeze_values: true)` to dry-configurable docs
12. Add installer command so as to generate an initializer with explained configs in `config/initializers/` folder

## Contribution

Help is welcome and much appreciated, whether you are an experienced developer or just looking for sending your first pull request or bug report.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CONTIOBUTIONS.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.md).
