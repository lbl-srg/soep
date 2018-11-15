.. _glossary:

Glossary
========

This section defines various technical terms that are used throughout
the report.

.. glossary::

   package
     In Modelica, a package is a collection of models, functions,
     or other packages that
     are used to hierarchically structure a Modelica library.

   class
     In Modelica, a *class* is a term that includes models, blocks, functions and packages.

   connector
     In Modelica, a connector is an instance of a class that is used to
     connect models and blocsk with each other.
     Connectors can contain constants, parameters and variables, but no equations.

   co-simulation
     Co-simulation refers to a simulation in which different simulation programs
     exchange run-time data at certain synchronization time points.
     A master algorithm sets the current time, input and states,
     and request the simulator to advance time, after which the
     master will retrieve the new values for the state.
     Each simulator is responsible for integrating in time its
     differential equation. See also :term:`model-exchange`.

   continous-time variable
     A continuous-time variable is a variable that is a continuous function
     of time inside each interval :math:`t_i^+ \le t \le \sideset{^-}{}t_{i+1}`.

   block
     In Modelica, a block is a special case of a model
     in which all connectors are either inputs or outputs.

   discrete-time variable
     A discrete-time variable is a variable that changes its value only at
     an event instant :math:`t_i`.

   events
     An event is either a :term:`time event` if time triggers the change,
     or a :term:`state event` if a test on the state triggers the change.

   model
     In Modelica, a model is a special class in which the causality
     of its connector need not be specified.

   model-exchange
     Model-exchange refers to a simulation in which different simulation programs
     exchange run-time data.
     A master algorithm sets time, inputs and states, and requests
     from the simulator the time derivative. The master algorithm
     integrates the differential equations in time.
     See also :term:`co-simulation`.


   zero-crossing function
     A zero crossing function is a function that is used by solvers to indicate
     when variables cross a threshold. For example, suppose a thermostat should switch
     off a heater when the room temperature :math:`T_r(t)` crosses a set point
     :math:`T_s(t)`. For this case, a zero crossing function is
     :math:`f(t) = T_r(t) - T_s(t)`.

     Zero-crossing functions are used by numerical solvers to detect where
     such discrete changes in a model occur. Specifically, at
     :math:`t=t_1`, they
     search for :math:`\tau \in \arg \min \{ t > t_1 \, | \, f(t) = 0 \}`.

   direct dependency
     A variable is said to directly depend on another variable if there is an
     algebraic constraint between these variables. For example, consider
     the model shown in :numref:`fig_direct_dependency`.
     If the input :math:`u` changes, then the output
     :math:`y_3` immediately changes, whereas :math:`y_1` and
     :math:`y_2` only change after time is advanced.
     Hence, the output :math:`y_3` is said to have a direct
     dependency on :math:`u`. Similarly, the state derivative :math:`\dot x_1`
     directly depends on the input :math:`u`, and
     :math:`\dot x_2` directly depends on the state :math:`x_1`.
     The outputs :math:`y_1` and :math:`y_2` directly depend
     on the states :math:`x_1` and :math:`x_2`, respectively.
     Hence, unless time is advanced,
     if :math:`u` is updated, only :math:`y_3` needs to
     be updated, whereas if :math:`y_1` and :math:`y_2`
     need not be updated.
     Such information is useful to detect the existence of
     algebraic loops, and to implement certain numerical time
     integration methods such as the QSS methods.

     .. _fig_direct_dependency:

     .. figure:: img/directDependency.*
        :width: 250px

        Signal flow diagram that illustrates direct dependency.


   Functional Mockup Interface
     The Functional Mockup Interface (FMI) standard defines an open interface
     to be implemented by an executable called :term:`Functional Mockup Unit` (FMU).
     The FMI functions are called by a simulator to create one or more instances of the FMU,
     called models, and to run these models, typically together with other models.
     An FMU may either be self-integrating (co-simulation) or require the simulator
     to perform the numerical integration.

   Functional Mockup Unit
     Compiled code or source code that can be executed using the
     application programming interface defined in the :term:`Functional Mockup Interface` standard.

   rollback
     We say that a simulator is doing a rollback if its model time is set to a previous
     time instant, and all its state variables are set to the values they had at that previous
     time instant.

   time event
     We say that a simulation has a time event if its model changes based on a test
     that only depends on time. For example,

     .. math::

        y =
        \begin{cases}
          0, & \text{if } t < 1, \\
          1, & \text{otherwise,}
         \end{cases}

     has a time event at :math:`t=1`.

   state event
     We say that a simulation has a state event if its model changes based on a test
     that depends on a state variable. For example, for some initial condition :math:`x(0)=x_0`,

     .. math::

        \frac{dx}{dt} =
        \begin{cases}
          1,  & \text{if } x < 1, \\
          0,  & \text{otherwise,}
        \end{cases}

     has a state event when :math:`x=1`.

   superdense time
      Superdense time :math:`t` is a tuple :math:`t \triangleq (t_R, \, t_I)`, where
      :math:`t_R \in \Re` and :math:`t_I \in \mathbb N`. The real part :math:`t_R` of this tuple
      is the independent variable for describing the :term:`continuous-time behavior<continuous-time variable>`
      of the model between events. In this phase, :math:`t_I = 0`.
      The integer part :math:`t_I` of this tuple is a counter to enumerate, and therefore distinguish,
      the events at the same continuous-time instant :math:`t_R` :cite:`LeeZheng2007:1`.
