+++
pretitle = "Averaging rotations"
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

## Introduction
We often take the [*arithmetic* mean](https://en.wikipedia.org/wiki/Arithmetic_mean), or *average* to be quite straightforward concept in mathematics.
For example, the average of two numbers, 1 and 3 is (1 + 3)/2 = 2.
But what about taking the average of two rotations?
The answer is not so straightforward, but I'll explain it in this article.
However, before diving into averaging rotations, let's first discuss what a *rotation* is in the context of this article.

\figenv{Multiple angles can represent the same rotation.}{/assets/averaging-rotations/heading.svg}{width:30%;}

Consider the blue arrow above, which is pointing in a top-right direction.
There are many ways to represent the direction of this arrow.
For example, it can be represented using the angle $\pi/4$ rotated in a counter clockwise direction from the horizontal, or using another angle such as $-7\pi/4$ in a clockwise direction from the horizontal.
In fact, there are infinitely many angles representing the rotation of this arrow.
For the purpose of this article, when I refer to a *rotation* or a *heading*, then I mean the "arrow direction" (i.e., think "top-right"), and when I refer to an *angle*, then I mean the number parametrizing the rotation or heading (e.g., $\pi/4$).

Reiterating the point above, the same arrow's rotation or heading can be represented using infinitely many angles (e.g., $\pi/4 + k2\pi$, where $k$ is an integer).
However, the heading is often represented using an angle $\theta$ in a Euclidean subspace of length $2\pi$.
For example, $\theta\in[0,2\pi)\sub\mathbb{R}$ or $\theta\in[-\pi, \pi)\sub\mathbb{R}$.


## Averaging rotations
Let's go back to the first question posed at the beginning of the article: what is the average of two rotations?
To get some insight into the problem, we'll start by looking at an example.

\figenv{The arithmetic mean of two angles is not necessarily the true mean of the two rotations.}{/assets/averaging-rotations/pi_semi_circles.svg}{width:40%;}

Consider the blue arrow pointing to the left in the figure above and assume there are two of them (i.e., one laying on top of the other).
Then, the average of the two rotations (i.e., the two blue arrows) should be the same (i.e., an arrow pointing to the left).
But, what about the average of the two *parametrizations*?
Let's make this interesting by assuming the two rotations are parametrized using the angles $\pi$ and $-\pi$.
The arithmetic mean of these two angles is $(\pi - \pi)/2 = 0$, which is a wrong answer; it's an arrow pointing to the *right*, which is shown as the yellow arrow in the figure above.


To further demonstrate the point, consider averaging the *same* rotations but now using a different angles.
Specifically, consider replacing $\pi$ with $3\pi$, which is still the *same* rotation represented using the angle $\pi$.
The arithmetic mean is then $(3\pi - \pi)/2 = \pi$, which is a correct answer.
Hmmm... what's going on here?

The examples above demonstrate how the heading representation (i.e., its *parameterization*) affects the "arithmetic angle average".
In this article, we'll dig into the reason behind this behaviour and then a solution is presented that solves the "rotation averaging" problem.
The answer uses the mathematics of [*Lie groups*](https://en.wikipedia.org/wiki/Lie_group), which are special manifolds that are are often used in robotics [[1]](#sola-micro-lie-theory), especially when describing rotations.
The subject of Lie groups is somewhat abstract and was difficult to learn when I was first introduced to the subject.
My attempt in this article is to motivate the usage of Lie groups through the example of rotation averaging.
I hope you enjoy the journey.

## Parametrizing headings
The first challenge in addressing the rotation averaging problem is to address how a rotation is *parametrized*.
That is, how can a rotation be *represented*.
One of the parametrizations was discussed earlier in this post, which uses real numbers (i.e., $\theta\in\mbb{R}$).
An issue with this parametrization is that the such parametrization is *not unique*.
That is, the *same* rotation can be represented using different angles.
Why is the non-uniqueness an issue in this case?

### The problem of non-unique parametrization
The reason that the non-uniqueness of a parametrization may cause issues is related to the notation of *distance*.
For example, given two angles $\theta_{1} = -\pi$ and $\theta_{2} = \pi$, then the *distance* from $\theta_{1}$ to $\theta_{2}$ is $\vert \theta_{2} - \theta_{1}\vert = 2\pi$.
However, the two angles represent the *same* rotation, so the distance should actually $0$.

The notion of distance is important as many areas of mathematics rely on it.
For example, the notion of distance always appears in calculus, which in turn is used all over smooth optimization theory, which is used in many engineering applications.
As such, having the correct notion of distance is important when using such mathematical tools.

### Bounding the number line
The problem of non-unique parameterization may be dealt with by defining the headings to belong to a continuous subset of length $2\pi$.
For example, the subset ${\theta\in[-\pi,\pi)\subset\mbb{R}}$.
Such parametrizations do solve the non-uniqueness problems and are often used in practice.

However, such parametrization is *not* a [*vector space*](https://en.wikipedia.org/wiki/Vector_space), which is a small setback.
Specifically, the set is not closed under addition or scaling.
That is, given two headings ${\theta_{1}\in[-\pi,\pi)}$ and ${\theta_{2}\in[-\pi,\pi)}$, then ${\theta_{1} + \theta_{2}\not\in[-\pi,\pi)}$, in general.

The reason that this is a setback is because many algorithms rely on linear algebra, which assume that the variables belong to a *vector space*.
For example, many numerical optimization algorithms (e.g., [Newton's method](https://en.wikipedia.org/wiki/Newton%27s_method_in_optimization)) rely on such assumption.

This setback will *not* be an issue if there is a way to keep using the mathematical tools developed using linear algebra while still using the bounded number line ${[-\pi,\pi)}$.
One way to do this is to exploit a [surjective mapping](https://en.wikipedia.org/wiki/Surjective_function) from the real number line $\mbb{R}$ to the bounded set ${[-\pi,\pi)}$.
This option is explored using complex numbers.

### Complex numbers
A different way to represent heading is by representing a point on a unit circle, which is a more natural way to represent headings.
This way, if two points lie on the same location on the unit circle then they have the same heading *and* parametrization.

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

### Simplified mappings
The mappings $\mbb{R}\to S^{1}$ and $S^{1}\to\mbb{R}$ will be used often, so explicitly defining functions representing these mappings will simplify the notation in this article.

Define the $\operatorname{Exp}(\theta):\mbb{R}\to S^{1}$ to be
\begin{align}
  \operatorname{Exp}(\theta) \coloneqq e^{\jmath\theta},
\end{align}
and $\operatorname{Log}: S^{1}\to[-\pi,\pi)\subset\mbb{R}$ to be
\begin{align}
  \label{eq:Log def}
  \operatorname{Log}(z) \coloneqq \log(z)/\jmath,
\end{align}
where $\operatorname{Log}$ is defined to return the angle in the range $[-\pi,\pi)$.

Another useful operation is the angle-wrapping operator $\operatorname{Wrap}: \mbb{R}\to[-\pi,\pi)$, which is a mapping taking any valid angle and wrapping it to the range $[-\pi, \pi)$.
For example, $\operatorname{Wrap}(3\pi) = \pi$.
Mathematically, the angle-wrap function can be defined as
\begin{align}
  \operatorname{Wrap}(\theta) \coloneqq \operatorname{Log}(\operatorname{Exp}(\theta)).
\end{align}

Now that the rotation parametrization using complex numbers is introduced, we can continue the rotation-averaging discussion.
Before deriving the method to average rotations parametrized using complex numbers, we will first discuss and derive the arithmetic mean, when expand on the arithmetic mean to apply it on rotations.

## Arithmetic mean derivation
In order to derive the rotation averaging algorithm, it helps to dig deeper into the arithmetic mean equation
\begin{align}
  \label{eq:mean}
  \bar{x}
  =
  \frac{1}{m}\sum_{i=1}^{m} x_{i},
\end{align}
which is valid for elements in a vector space $x_{i}\in\mathcal{V}$ (e.g., $\mathcal{V} = \mbb{R}^{n}$).
Deriving the arithmetic mean will provide the basis for deriving the rotation averaging algorithm.

One way to think about the mean of a set of elements $\mathcal{X}=\{x_{1}, \ldots, x_{m}\}$, where $x_{i}\in \mathcal{V}$, is that it's the number $\bar{x}\in\mathcal{V}$ closest to all the numbers in the set, on average.
But what does this statement mean mathematically?
There are two points in the above statement that will help in formulating the above statement mathematically:
first, the notion "closest" implies the minimum *distance*, so we need to define the *distance* on the given set;
second, the notion "on average" implies reducing the *distance* on aggregate (i.e., on all elements), and not on a specific element.

Let's go back to the arithmetic mean to make the example more concrete.
The notion of distance for the Euclidean space $\mbb{R}^{n}$ is defined as
\begin{align}
  d(x_{1}, x_{2}) = \Vert x_{1} - x_{2}\Vert_{2}.
\end{align}

Thus, the distance between the mean $\bar{x}$ and the element $x_{i}$ can be defined as
\begin{align}
  \label{eq:arithmetic mean error distance}
  d_{i}(\bar{x}) \coloneqq d(\bar{x}, x_{i}) = \Vert \bar{x} - x_{i} \Vert_{2} \eqqcolon \Vert e_{i}(\bar{x}) \Vert_{2},
\end{align}
where
\begin{align}
  \label{eq:linear-error-function}
  e_{i}(\bar{x}) \coloneqq \bar{x} - x_{i}
\end{align}
is referred to as the *error function* because it's measuring the difference between the mean $\bar{x}$ (i.e., the target variable) and the $n$-th element $x_{i}$.

The mean $\bar{x}\in\mathcal{V}$ is then the element that minimizes the *total* distance given by
\begin{align}
  \label{eq:objective-function-distance}
  \tilde{J}(\bar{x})
  \coloneqq
  \sum_{i=1}^{m} d_{i}(\bar{x})
  =
  \sum_{i=1}^{m} \Vert e_{i}(\bar{x})\Vert_{2},
\end{align}
which can be written mathematically as
\begin{align}
  \label{eq:argmin-sum-of-distances-newton}
  \bar{x} = \operatorname{arg.\,min}_{x\in\mathcal{V}} \sum_{i=1}^{m} \Vert e(x) \Vert_{2},
\end{align}
where $\operatorname{arg.\,min}$ is read as the "argument of the minimum".

Since \eqref{eq:linear-error-function} is an error function, then \eqref{eq:argmin-sum-of-distances-newton} is a (linear) [*least squares problem*](https://en.wikipedia.org/wiki/Least_squares).
Without going into details, squaring the summands in \eqref{eq:argmin-sum-of-distances-newton} makes the optimization problem convex, which has strong mathematical guarantees.
As such, the objective function \eqref{eq:objective-function-distance} is modified to be
\begin{align}
  J(\bar{x})
  \coloneqq
  \sum_{i=1}^{m} d_{i}(\bar{x})^{2}
  =
  \sum_{i=1}^{m} e_{i}(\bar{x})^{\mathsf{T}}e_{i}(\bar{x}),
\end{align}
which in turn changes the optimization problem \eqref{eq:argmin-sum-of-distances-newton} to be
\begin{align}
  \label{eq:argmin-least-squares-newton}
  \bar{x} = \operatorname{arg.\,min}_{x\in\mathcal{V}} \sum_{i=1}^{m} e_{i}(x)^{\mathsf{T}}e_{i}(x).
\end{align}
Equation \eqref{eq:argmin-least-squares-newton} can be written in lifted form (i.e., using matrices)
\begin{align}
  \label{eq:argmin-least-squares-newton}
  \bar{x} = \operatorname{arg.\,min}_{x\in\mathcal{V}} \Vert A{x} - b \Vert_{2}^{2},
\end{align}
where
\begin{align}
  A
  =
  \begin{bmatrix}
    \mbf{1} & \cdots & \mbf{1}
  \end{bmatrix}^{\mathsf{T}} \in \mbb{R}^{mn \times n}, \;
  \text{and}\;
  b
  =
  \begin{bmatrix}
    x_{1}^{\mathsf{T}} & \cdots & x_{m}^{\mathsf{T}}
  \end{bmatrix}^{\mathsf{T}} \in \mbb{R}^{mn}.
\end{align}

The solution to the least squares problem \eqref{eq:argmin-least-squares-newton} [is](https://en.wikipedia.org/wiki/Least_squares#:~:text=Setting%20the%20gradient%20of,%2C%20we%20get%3A) [[2]](#barfoot-state-estimation) 
\begin{align}
  \bar{x}
  =
  (A^{\mathsf{T}}A)^{-1}A^{\mathsf{T}}b
  =
  \left(m\mbf{1}\right)^{-1}\left(\sum_{i=1}^{m}x_{i}\right)
  =
  \frac{1}{m} \sum_{i=1}^{m} x_{i},
\end{align}
which matches \eqref{eq:mean}.

For further reading into least squares and optimization, [[3]](#nocedal) is a classic.

The generalization of the linear least squares problem is the [nonlinear least squares](https://en.wikipedia.org/wiki/Non-linear_least_squares), which is used in deriving the rotation-averaging equation in the next section.

## Averaging rotations using complex numbers
The rotation averaging algorithm is an on-manifold nonlinear least squares algorithm implemented, where the manifold in this case is the unit circle $S^{1}$.
The algorithm is very similar to the arithmetic mean equation derived in the previous section, so we'll follow a similar path to derive the rotation averaging algorithm.

As previously discussed, the rotations will be parametrized using complex numbers \eqref{eq:s1-exp-map}.
And as was done with the arithmetic mean, we need a *distance* metric $\tilde{d}:S^{1}\times S^{1}\to\mbb{R}_{\geq0}$ to measure the distance between two rotations,
which in this case is given by
\begin{align}
  \label{eq:complex distance}
  \tilde{d}(z_{1}, z_{2}) = \Vert \operatorname{Log}(z_{1}z_{2}^{\ast}) \Vert_{2},
\end{align}
where $z^{\ast}$ is the [complex conjugate](https://en.wikipedia.org/wiki/Complex_conjugate), and $\operatorname{Log}$ is defined in \eqref{eq:Log def}.

Similar to the error function introduced in \eqref{eq:arithmetic mean error distance}, the distance between the mean $\bar{z}$ and the $i$th rotation $z_{i}$ is given by
\begin{align}
  \tilde{d}_{i}(\bar{z}) \coloneqq \tilde{d}(\bar{z}, z_{i}) \eqqcolon \Vert \tilde{e}_{i}(\bar{z}) \Vert_{2},
\end{align}
where
\begin{align}
  \label{eq:error function complex}
  \tilde{e}_{i}(\bar{z}) = \operatorname{Log}(\bar{z}_{i}z_{i}^{\ast})
\end{align}
is the *error function* between the mean $\bar{z}$ and the $i$th rotation $z_{i}$.

It important to note that the error function \eqref{eq:error function complex} is smooth in both arguments.
Without the smoothness of the distance function, it's not possible to use the nonlinear least squares algorithm, which is used in the following steps.

The rotation average is then the solution to the optimization problem
\begin{align}
  \label{eq:argmin on complex space}
  \bar{z} = \operatorname{arg.\,min}_{z\in S^{1}} \sum_{i=1}^{m} \tilde{e}_{i}(z)^{2}.
\end{align}

The optimization problem \eqref{eq:argmin on complex space} looks nice in theory, but unfortunately, it's not very straightforward to solve.
As such, we turn to parametrizing the rotations using angles, as was introduced in \eqref{eq:s1-exp-map}.
Specifically, I will use the notation
\begin{align}
  z(\theta) \coloneqq \operatorname{exp}(\jmath\theta).
\end{align}

Then, the error function \eqref{eq:error function complex} becomes
\begin{align}
  \label{eq:argmin on algebra space}
  e_{i}(\bar{\theta}) = \tilde{e}_{i}(z(\bar{\theta})) = \operatorname{Log}(z(\bar{\theta})z(\theta_{i})^{\ast})
  = \operatorname{Log}(\operatorname{Exp}(\bar{\theta} - \theta_{i}))
  = \operatorname{Wrap}(\bar{\theta} - \theta_{i}).
\end{align}

The optimization problem \eqref{eq:argmin on complex space} becomes
\begin{align}
  \label{eq:argmin on algebra space}
  \bar{\theta} = \operatorname{arg.\,min}_{\theta\in \mbb{R}} \sum_{i=1}^{m} e_{i}(\theta)^{2}.
\end{align}

The optimization problem \eqref{eq:argmin on algebra space} is a non-convex nonlinear least squares problem, which can be solved using the various methods such as the [Gauss Newton algorithm](https://en.wikipedia.org/wiki/Gauss%E2%80%93Newton_algorithm).
The Gauss Newton method is a gradient-based optimization method, which means that it requires and uses the error function Jacobian to iterate over the current solution, until convergence.
As such, the Jacobian of the error function \eqref{eq:argmin on algebra space} is needed.

The Jacobian of the error function \eqref{eq:argmin on algebra space} can be computed by expanding the error function using its Taylor series approximation.
Let $\bar{\theta}$ be the operating point to linearize about, and let $\theta = \bar{\theta} + \delta\theta$, where $\delta\theta$ is the perturbation.
Then, the error function can be expressed as
\begin{align}
  e_{i}(\theta) 
    = e_{i}(\bar{\theta} + \delta\theta)
    = \operatorname{Log}(\operatorname{Exp}(\bar{\theta} + \delta\theta - \theta_{i}))
    \approx \operatorname{Log}(\operatorname{Exp}(\bar{\theta}-\theta_{i})) + \operatorname{Log}(\operatorname{Exp}(\delta\theta))
    = e_{i}(\bar{\theta}) + \delta\theta.
\end{align}
As such, the Jacobian is
\begin{align}
  \mathbf{J}_{i} \coloneqq \frac{\mathrm{d}e_{i}(\theta)}{\mathrm{d}\theta} = 1.
\end{align}

The error functions can be stacked into a single column vector
\begin{align}
  \label{eq:lifted error func}
  \mbf{e}(\theta) =
  \begin{bmatrix} e_{1}(\theta) & \cdots & e_{m}\end{bmatrix}^{\mathsf{T}} \in \mbb{R}^{m},
\end{align}
and its Jacobian is given by
\begin{align}
  \label{eq:lifted error jacobian}
  \mbf{J} \coloneqq \frac{\mathrm{d}\mbf{e}(\theta)}{\mathrm{d}\theta} = \begin{bmatrix}1 & \cdots & 1\end{bmatrix}^{\mathsf{T}}.
\end{align}
The Gauss Newton algorithm is an iterative algorithm given by
\begin{align}
  \theta^{k+1} = \theta^{k} + \delta\theta^{k},
\end{align}
where $\delta\theta$ is the search direction (also known as the update step), and is given by solving the system of equations
\begin{align}
  \label{eq:GN system of equations}
  \mbf{J}(\theta^{k})^{\mathsf{T}}\mbf{J}(\theta^{k})\delta\theta^{k}
    = -\mbf{J}(\theta^{k})^{\mathsf{T}}\mbf{e}(\theta^{k}),
\end{align}.

Inserting the error function \eqref{eq:lifted error func} and the block Jacobian \eqref{eq:lifted error jacobian} into the system of equations \eqref{eq:GN system of equations} and solving for the search direction $\delta\theta^{k}$ gives the solution
\begin{align}
  \delta\theta^{k}
  =
  -\frac{1}{m}\sum_{i=1}^{m} \operatorname{Log}(\operatorname{Exp}(\theta^{k} - \theta_{i}))
  =
  -\frac{1}{m}\sum_{i=1}^{m} \operatorname{Wrap}(\theta^{k} - \theta_{i}).
\end{align}
The rotation averaging equation is then
\begin{align}
  \label{eq:iterative rotation averaging}
  \theta^{k+1} = \theta^{k} - \frac{1}{m}\sum_{i=1}^{m} \operatorname{Wrap}(\theta^{k} - \theta_{i}).
\end{align}

Given that the rotation averaging equation \eqref{eq:iterative rotation averaging} is an iterative equation, it needs to be *initialized* using a starting guess $\theta^{0}$.
Due to the nonconvexity of the optimization problem, there may be local minimums that are different from the global minimum.
As such, the initial value $\theta^{0}$ plays a huge role in determining whether the algorithm converges to a local or a global minimum.

Some examples will be introduced in the next section that shed some light on this issue.

### Examples
- Show how starting with different angles result in different answers, which is due to the non-convexity of the problem.

## Summary
- Why you should care
- How this can be used
- Motivation into Lie groups

## References
1. \anchor{sola-micro-lie-theory} J. Solà, J. Deray, and D. Atchuthan, “*A micro Lie theory for state estimation in robotics*,” [arXiv:1812.01537](https://arxiv.org/pdf/1812.01537.pdf) [cs], Dec. 2021, Accessed: Mar. 20, 2022.
2. \anchor{barfoot-state-estimation} T. D. Barfoot, State Estimation for Robotics. Cambridge, MA, USA: 774 Cambridge Univ. Press, 2017. 
3. \anchor{nocedal} J. Nocedal and S. J. Wright, Numerical optimization, 2nd ed. in Springer series in operations research. New York: Springer, 2006.

