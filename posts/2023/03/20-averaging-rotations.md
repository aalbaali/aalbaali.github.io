+++
pretitle = "Rotation averaging"
title = "Averaging rotations"
mintoclevel = 2

descr = """
    A motivational introduction to Lie groups
    """
tags = ["Lie groups", "optimization"]
+++

# {{pretitle}}

{{page_tags}}

\toc

## Arithmetic means
The *arithmetic* mean, or *average* of two numbers, say 1 and 3, is (1 + 3)/2 = 2.
This come as no surprise.

What about the average of two rotations?
Say we're given two *representations* of the *same* rotation, $\pi$ and $-\pi$.
Since the two rotations are the same, as demonstrated in the figure below, their mean should be $k\pi$, where $k\in\mbb{Z}$ is any integer.
However, if we take the arithmetic mean, then we'd get $(\pi - \pi)/2 = 0$, which is a wrong answer.
There's clearly something interesting when averaging rotations.

\figenv{The arithmetic mean of two rotations is not necessarily the true mean.}{/assets/averaging-rotations/pi_semi_circles.svg}{width:30%;}

To further demonstrate the point, consider averaging the *same* rotations but using yet another representation.
For example, consider replacing $\pi$ with $3\pi$, which is still the *same* heading $\pi$.
The arithmetic mean is then $(3\pi - \pi)/2 = \pi$, which is a correct answer.

The examples above demonstrate how the heading representation (i.e., its *parameterization*) affects the "averaging rotation" answer.
The reason behind this behaviour is discussed in this post and then is followed by presenting a solution to solving this problem, which involves delving into [*Lie groups*](https://en.wikipedia.org/wiki/Lie_group), which are special manifolds.
These groups are often used in robotics [[1]](#sola-micro-lie-theory), especially when describing rotations.
The subject of Lie groups is an abstract one that is difficult to get into.
When I was first introduced into the subject, it was difficult to see the motivation behind using such mathematical structures to solve, what seemed to me, as "easy" problems.
My aim in this post is to motivate Lie groups by introducing them as a solution to the *rotation averaging* problem introduced above.

The post starts by giving a glimpse into representing heading using complex numbers and matrices known as *rotation matrices*.
A through derivation of the *arithmetic* mean is then presented, which is then generalized to compute the *on-manifold* mean (since the space of rotations is a manifold).

## Parametrizing headings
The first challenge in addressing the rotation averaging problem is to address how a rotation is *parametrized*.
That is, how can a rotation be *represented*.
One way to do that is to parametrize headings using real numbers (i.e., $\theta\in\mbb{R}$).
An issue with this parametrization is that the such parametrization is *not unique*.
That is, the *same* rotation can be represented using different parametrizations.
For example, the same heading $\theta$ can be parametrized using $\theta + 2\pi k$ for any integer $k\in\mbb{Z}$.
But why does that pose a problem?

### The problem of non-unique parametrization
The reason that the non-uniqueness of a parametrization may cause issues is related to the notation of *distance*.
For example, assuming that the headings $\theta$ belong to the real number line $\mbb{R}$, then given two headings $\theta_{1} = -\pi$ and $\theta_{2} = \pi$, the *distance* from $\theta_{1}$ to $\theta_{2}$ is $\vert \theta_{2} - \theta_{1}\vert = 2\pi$.
However, from our understanding of headings, we know that $\theta_{1}$ and $\theta_{2}$ point in the same direction, hence they are *same* heading, and the distance should actually be $0$.

Many areas of mathematics rely on the notion of *distance*.
For example, the notion of distance always appears in calculus, which in turn is all over smooth optimization theory used in many engineering applications.
As such, having the correct notion of distance is important before using such mathematical tools.

### Bounding the number line
The problem of non-unique parameterization may be dealt with by defining the headings to belong to a continuous subset of length $2\pi$.
For example, the subset ${\theta\in[-\pi,\pi)\subset\mbb{R}}$.
Such parametrizations do solve the non-uniqueness problems and are often used in practice.

Such parametrization is *not* a [*vector space*](https://en.wikipedia.org/wiki/Vector_space), which is a small setback.
Specifically, the set is not closed under addition or scaling.
That is, given two headings ${\theta_{1}\in[-\pi,\pi)}$ and ${\theta_{2}\in[-\pi,\pi)}$, then ${\theta_{1} + \theta_{2}\not\in[-\pi,\pi)}$, in general.

The reason that this is a setback is because many algorithms rely on linear algebra, which assume that the variables belong to a *vector space*.
For example, many numerical optimization algorithms (e.g., [Newton's method](https://en.wikipedia.org/wiki/Newton%27s_method_in_optimization)) rely on such assumption.

As such, this setback will *not* be an issue if there is a way to keep using the mathematical tools developed using linear algebra while still using the bounded number line ${[-\pi,\pi)}$.
One way to do this is to exploit a [surjective mapping](https://en.wikipedia.org/wiki/Surjective_function) from the real number line $\mbb{R}$ to the bounded set ${[-\pi,\pi)}$.
This option is explored using complex numbers in the next section.

### Complex numbers
A more natural way to represent headings is to represent points on a unit circle.
This way, if two points lie on the same location on the unit circle then they have the same heading.

The complex unit circle
\begin{align}
  S^{1} \coloneqq \left\{z : \vert z \vert = 1\right\}
\end{align}
is an elegant way to represent headings.
It addresses the parameterization uniqueness issue previously discussed, where a heading is *uniquely* represented using a *single* complex number $z\in S^{1}$.
The notation $S^{1}$ is used to denote that it's a *one-dimensional sphere* [[1]](#sola-micro-lie-theory).

The unit circle $S^{1}$ is not a vector space, which is the same issue presented when using the set ${[-\pi,\pi)}$.
However, complex numbers can be used to remedy this issue.
A point $z\in S^{1}$ on the unit circle can be parameterized by
\begin{align}
  \label{eq:s1-exp-map}
  z = e^{\jmath \theta},
\end{align}
where $\theta\in\mbb{R}$ is *not* a unique number.
This allows us to use the linear algebra tools on $\theta\in\mbb{R}$ and then map them to the unit circle $S^{1}$ using the mapping \eqref{eq:s1-exp-map}.
For instance, two headings ${\theta_{1},\theta_{2}\in\mbb{R}}$ can be added since they are in a vector space $\mbb{R},$ and then *mapped* to the unit circle using the exponential map \eqref{eq:s1-exp-map}, which is a smooth map.
For example, given two headings $z_{1}, z_{2}\in S^{1}$ parameterized by ${\theta_{1},\theta_{2}\in\mbb{R}}$, respectively.
Then their added heading is
\begin{align}
  z_{3} = z_{1} z_{2} = e^{\jmath\theta_{1}}e^{\jmath\theta_{2}} = e^{\jmath(\theta_{1} + \theta_{2})}.
\end{align}

The parameter $\theta_{3}$ such that $z_{3} = e^{\jmath\theta_{3}}$ is computed using the *inverse map*, which is the logarithm map $\log$.
The logarithm map does *not* have a unique solution because the exponential map \eqref{eq:s1-exp-map} is a surjective map, which means that there's a unique mapping from $\mbb{R}$ to $S^{1}$, but not necessarily the other way around.
That is, there may exist two different parameters $\theta_{1}\neq\theta_{2}$, $\theta_{1}, \theta_{2}\in\mbb{R}$ that have the same heading $e^{\jmath\theta_{1}}=e^{\jmath\theta_{2}}$.
Thus, the logarithm map is instead defined as
\begin{align}
  \log(z) = \{\jmath\theta : e^{\jmath\theta} = z\}.
\end{align}
For example, $\log(1 + 0\jmath) = \jmath 2\pi k$, where $k\in\mbb{Z}$.

The reference [[1]](#sola-micro-lie-theory) has a good introduction to Lie groups including this one with visuals and demonstrative examples.
### The Lie algebra

### Wrapping angles
Essentially
\begin{align}
  \operatorname{Wrap}(\theta) = \operatorname{Log}(\operatorname{Exp}(\theta)).
\end{align}

### Extra



Demonstrate, using a good (optimization) example, why non-uniqueness poses issues.

The notation of a "distance".
What's the distance between $\theta_{1} = -\pi$ and $\theta_{2} = \pi$? Is it $\theta_{2} - \theta_{1} = 2\pi$?
<!-- Why is non-uniqueness an issue here?? -->
The non-uniqueness issue of the parametrization causes issues

Rotations, or headings, have an interesting structure.
Two dimensional rotations, or headings, tend to be represented using a real number that has a range of $2\pi$.
For example, ${\theta\in[0, 2\pi)}$ or ${\theta\in[-\pi,\pi)}$.

The examples introduced in the previous section demonstrate that rotations behave differently than regular numbers.

## References
1. \anchor{sola-micro-lie-theory} J. Solà, J. Deray, and D. Atchuthan, “*A micro Lie theory for state estimation in robotics*,” [arXiv:1812.01537](https://arxiv.org/pdf/1812.01537.pdf) [cs], Dec. 2021, Accessed: Mar. 20, 2022
