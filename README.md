__elixir-pdx/zee_pipes__

---
#Overview

This exercise is designed to be an introduction to the Elixir Pipelines feature/functionality.

A zombie scourge has started to infiltrate the regular population.  Humanity may be on the brink of its greatest achievement or its eminent demise.  We'll need to act fast to understand the data that's been collected on zombie encounters thus far.

Your challenge is processing the [Medical Sample Data] (https://www.dropbox.com/s/adza0feenghlm5u/medical_screening_samples.tar.gz?dl=1) collected from reported zombie attacks and encounters to hunt for potentially useful correlations that can help medical experts and security forces plan for how to proceed.  Initially we're looking for samples that contain the DNA sequence TAGTAAG, whether or not gender is a strong correlator to zombification, and the min/max/mean weight of the known zombie population.

**Stretch Goal:** Given the urgency of the problem, it will be imperative to try and create a pipeline that can execute as quickly as possible, so parallelization should be a goal when possible.

**Prerequisites:**
* [elixir](http://elixir-lang.org/install.html)
* [Medical Sample Data] (https://www.dropbox.com/s/adza0feenghlm5u/medical_screening_samples.tar.gz?dl=1)

---

#Getting Started

###Clone this repository.
  
    $ cd ~/Repositories
    $ git clone https://github.com/elixir-pdx/zee_pipes.git
    $ cd zee_pipes

#Hacking

You may find it helpful to play with your code in Elixir's `iex` interactive console. If you want to do that and autoload the console session with your code then you can do the following from the project root:

    $ iex -S mix

That will make sure that you're running `iex` inside your project's build environment.

#Building

To compile your project simply run this from the project root:

    $ mix compile

#Testing

To run the test suite defined in `test/zee_pipes_test.exs` then run this from the project root:

    $ mix test
