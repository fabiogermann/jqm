﻿# JQM

## Introduction

JQM (short for Job Queue Manager) is a middleware allowing to runs arbitrary Java code asynchronously on a distributed network of servers.
It is useful for adding a level of control between a job execution request and its technical execution - the two most obvious needs being:

* getting long running jobs out of the application server. An application server is not supposed to handle these, which fill up its 
queues and often end in weird timeouts and runaway threads. JQM will host these externalized jobs in an async way, not requiring the application server 
to wait for completion.
* job execution query frequency adaptation. Often a job is requested to run multiple times at the same moment (either by a human request, or an automated 
system reacting to frequent events, ...) while the job should actually run only one at a time (e.g. the job handles all available data at the time of its 
launch - so there is really no need for multiple instances in parallel). JQM will throttle these requests.

Most of the time, the code that can be run by JQM will be a direct reuse of existing code without modifications (for jars with a main function,
or Runnables). But is also optionaly offers a rich API that allows running code to ask for another execution, to retrieve structured parameters,
send messages and other advancement notices... Also of note, JQM is pure Java Standard Edition 6 (JSE 1.6) to enable not only code but binary reuse.

Interacting with JQM is also easy: an API, with two different implementations for different needs, is offered to do every imaginable operation (new
execution request, querying the state of a request, retrieving files created by a job instance, ...).

Finally, JQM was created with compatibility in mind:

* uses either MySQL, Oracle or HSQLDB
* the client API is usable in all application servers and JSE code (tested with WebsSphere 8.x, Glassfish 3.x, Tomcat 7.x)
* one of the client API implementations is a REST-like API, callable from everywhere, not only Java but also .NET or shell scripts (allows easy
scheduler integration).
* Java SE 1.6, the current lowest common denominator of the Java world.

## Documentation

1. [How it works](archi.md) - read first, contains definitions!
2. [Installation](install.md)
3. Jobs
  1. [Writing a job](writing_payloads.md)
  2. [Using JNDI resources inside a job](resources.md)
  3. [Packaging a job](packaging.md)
4. Clients
  1. [The client API](client.md)
  2. [Hibernate client API specifics](hibernateclient.md)
  3. [Web service client API specifics](webservice.md)
5. Administration
  1. Basic operations (start, stop...)
  2. Logs
  3. Other monitoring
  4. [Command line reference](cli.md)
6. [Troubleshooting](troubleshooting.md)
7. [Contributing](contrib.md)
  
## Bug report

Reports bugs or features requests on [github](https://github.com/enioka/jqm/issues)