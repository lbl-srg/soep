.. _sec_conventions:

Conventions
-----------

#. We use the notation :math:`a \triangleq b` to denote that :math:`a` is equal to :math:`b` by definition.

#. We denote by :math:`\Re` the set of real numbers,
   by :math:`\mathbb Z` the set of integers and
   by :math:`\mathbb N \triangleq \{0, \, 1, \, \ldots \}` the set of natural numbers.
   The set :math:`\mathbb N_+` is defined as :math:`\mathbb N_+
   \triangleq \{1, \, 2, \, \ldots \}`.

#. :math:`f(\cdot)` denotes a function where
   :math:`(\cdot)` stands for the undesignated variables.
   :math:`f(x)` denotes the value of :math:`f(\cdot)` at the point
   :math:`x`.
   :math:`f\colon A \rightarrow B` indicates that the domain of :math:`f(\cdot)`
   is in the space :math:`A` and its range in the space :math:`B`.

#. We say that a function :math:`f \colon \Re^n \to \Re` is
   once continuously differentiable
   if :math:`f(\cdot)` is defined on :math:`\Re^n`,
   and if :math:`f(\cdot)` has a continuous derivative on
   :math:`\Re^n`.

#. For :math:`f \colon \Re \to \Re`,
   we denote by :math:`f^{(N)}(\cdot)` its :math:`N`-th derivative.

#. For :math:`f \colon \Re \to \Re` and :math:`t \in \Re`,
   we denote by :math:`f(t^-) \triangleq \lim_{s \uparrow t}  f(s)` the limit from below.

#. For :math:`s \in \Re`, we define the ceiling function as
   :math:`\lceil s \rceil \triangleq \arg \min\{ k \in \mathbb Z \ | \ s \le k \}`.

#. For :math:`t_R \in \Re` and :math:`t_I \in \mathbb N`, we write
   :math:`t^+ \triangleq (t_R, \, t_I)^+` for the right limit at :math:`t`.
   It holds that
   :math:`(t_R, \, t_I)^+ \Leftrightarrow (\lim_{\epsilon \to 0} (t_R+\epsilon), t_{I_{max}})`,
   where :math:`I_{max}` is the largest occuring integer of :term:`superdense time`.
   Similarly, we write :math:`\sideset{^-}{}t` for the left limit at :math:`t`,
   for which it holds that
   :math:`\sideset{^-}{}(t_R, \, t_I) \Leftrightarrow (\lim_{\epsilon \to 0} (t_R-\epsilon), 0)`.

#. We write a requirement *shall* be met if it must be fulfilled.
   If the feature that implements a shall requirement is not in the final system,
   then the system does not meet this requirement.
   We write a requirment *should* be met if it is not critical
   to the system working, but is still desirable.
