+++
pretitle = "Reference frames and transformations"
title = "Reference frames and transformations"
mintoclevel = 2

descr = """
        A gentle introduction to reference frames and transformation matrices
    """
tags = ["Kinematics", "Lie groups"]
+++

# {{pretitle}}

{{page_tags}}


# Motivation
Say you want to design a localization system for a ground robot equipped with wheel encoders, an IMU, and a Lidar.
The goal of the navigation system is to estimate the robot's [pose](https://en.wikipedia.org/wiki/Pose_(computer_vision)#:~:text=In%20computer%20vision%2C%20the%20pose,and%20orientation%20in%20the%20environment.) (i.e., position and orientation) resolved in the *world* frame (i.e., as seen by an observer in the world looking at the robot).
To do that, the navigation system would need to resolve the sensor measurements (e.g., lidar measurements) in the *robot* frame.
In other words, the system should *transform* the measurements from the sensor frame to the robot frame.
This requires using transformations, which can be parametrized as transformation matrices, which in turn are a relation between two coordinate systems.

\figenv{A robot equipped with multiple sensors.}{/assets/frames-and-transforms/robot_frames.svg}{width:30%;}

This blog serves as a very lightweight intro to the notion of reference frames and transformations that link frames and positions together.

# Reference frames
I've been talking about reference frames and transforms without giving them a proper introduction.
So, I'll try to give a clearer intro to these concepts, and I'll use visuals to help me with this intro.
Refer to [^1][^2] for more info on frames and transforms.

A reference frame, denoted $\mathcal{F}$, is a set of orthogonal physical unit vectors.
The frame can be attached to a rigid body such that it rotates with the rigid body.
However, the reference frame does *not* have a notion of "position", which could be a confusing concept, especially that the frames are often drawn with an "origin".
What's usually meant to be communicated is "the position of some point $a$ with respect to another point $b$, resolved in frame $\mathcal{F}_{a}$".

For example, the vector from point $w$ to point $p$ is represented using a *physical vector* $\underrightarrow{r}^{pw}$.
\figenv{Physical vector in the physical space.}{/assets/frames-and-transforms/frames_physical_vector.svg}{width:30%;}

To make sense of the physical vector $\underrightarrow{r}^{pw}$, a reference frame needs to be defined in which the physical vector can be *resolved*.
Let's define an arbitrary frame $\mathcal{F}_{a}$ and resolve the physical vector.
The physical vector $\underrightarrow{r}^{pw}$ resolved in frame $\mathcal{F}_{a}$ is denoted by $\mathbf{r}^{pw}_{a}$, as seen below.
\figenv{Physical vector resolved in an arbitrary frame.}{/assets/frames-and-transforms/frames_disp_pw_a.svg}{width:40%;}

As mentioned previously a frame does *not* have a position.
For example, let's define another frame $\mathcal{F}_{a'}$ that is aligned (i.e., the arrows are in the same direction) with frame $\mathcal{F}_{a}$ but is *visualized* as if it was displaced.
Then the vector $\underrightarrow{r}^{pw}$ resolved in frame $\mathcal{F}_{a'}$, $\mathbf{r}^{pw}_{a'}$ has the same value as $\mathbf{r}^{pw}_{a}$.
\figenv{A frame does not have a notion of position.}{/assets/frames-and-transforms/frames_disp_pw_a_prime.svg}{width:60%;}

However, if the two frames are misaligned (i.e., the vectors are pointing in different directions), then the resolved values (i.e., the coordinates are different).
For example, defining a frame $\mathcal{F}_{b}$ that has its x-axis aligned with the physical vector $\underrightarrow{r}^{pw}$ will have different coordinates than $\mathbf{r}^{pw}_{a}$.
\figenv{The resolved vector coordinates are different if the two frames are misaligned.}{/assets/frames-and-transforms/frames_disp_pw_b.svg}{width:45%;}

The frames $\mathcal{F}_{a}$ and $\mathcal{F}_{b}$ are related to one another through a rotation matrix, also known as a direction cosine matrix (DCM)[^3].
The rotation matrix $\mathbf{C}_{ab}$ consists of the vectors of the frame $\mathcal{F}_{b}$ resolved in the frame $\mathcal{F}_{a}$.
For the given example above, the matrix is given by
$$
\mathbf{C}_{ab}
=
\begin{bmatrix}
\cos(\theta_{ba}) & -\sin(\theta_{ba})\\
\sin(\theta_{ba}) & \cos(\theta_{ba})
\end{bmatrix},
$$
where $\theta_{ba}$ is the angle from frame $\mathcal{F}_{a}$ to frame $\mathcal{F}_{b}$.
For the example above, the angle is $\theta_{ba} = \tan^{-1}(1 / 2)$.

The rotation matrix is useful because it can be used to relate the coordinates of a physical vector resolved in different frames.
For example,
$$
\mathbf{r}^{pw}_{a}
=
\mathbf{C}_{ab}
\mathbf{r}^{pw}_{b}.
$$

# Transformations
The rotation matrices are useful to relate vector coordinates resolved in different frames.
However, sometimes we're interested in more than just resolving the vector in a different frame.
Specifically, we're sometimes interested in having the displacement be with respect to *another* point, resolved in a *different* frame.

For example, say we have the coordinates $\mathbf{r}^{pw}_{a}$.
\figenv{}{/assets/frames-and-transforms/transform_frame_a.svg}{width:20%;}

Furthermore, say we're interested in having the coordinates of $\mathbf{r}^{pz}_{b}$.
That is, the displacement of the point $p$ with respect to point $z$, resolved in frame $\mathcal{F}_{b}$ (i.e., the orange arrow in the image blow).
\figenv{}{/assets/frames-and-transforms/transform_frame_b.svg}{width:45%;}
Then, what is the relation between $\mathbf{r}^{pw}_{a}$ and $\mathbf{r}^{pz}_{b}$?

Well, this be relatively simple:
$$
\mathbf{r}^{pw}_{a}
=
\mathbf{C}_{ab}
\mathbf{r}^{pz}_{b}
+
\mathbf{r}^{zw}_{a},
$$
which can be written compactly as
$$
\begin{bmatrix}
\mathbf{r}^{pw}_{a} \\
1
\end{bmatrix}
=
\underbrace{
\begin{bmatrix}
\mathbf{C}_{ab} &
\mathbf{r}^{zw}_{a} \\
\mathbf{0} & 1
\end{bmatrix}
}_{\mathbf{T}^{zw}_{ab}}
\begin{bmatrix}
\mathbf{r}^{pz}_{b} \\
 1
\end{bmatrix},
$$
where $\mathbf{T}^{zw}_{ab}$ is known as a [transformation matrix](https://en.wikipedia.org/wiki/Transformation_matrix), and $\begin{bmatrix}\mathbf{r} & 1\end{bmatrix}^{\mathsf{T}}$ is known as a [homogenous coordinate](https://en.wikipedia.org/wiki/Homogeneous_coordinates).


# Applications
Transformation matrices, and transformations in general are quite important in many fields that use kinematics such as aerospace, robotics, vehicles, and many others.
The reason they are important is because there are often multiple important frames on a robot.

For example, sensor data (e.g., lidar) are resolved in the sensor frame.
However, robotic systems, such as the navigation system, would require the sensor data be resolved in the body frame.
As such, the transformation matrices between these frames are important for such a system.
\figenv{A robot is usually equipped with multiple frames. Usually each sensor has its own frame.}{/assets/frames-and-transforms/robot_frames.svg}{width:30%;}

These transformation matrices are often estimated using calibration processes, often referred to as extrinsic calibration.

# Concluding remarks
This blog was intended to be a light-weight introduction to the applications of reference frames and transformation matrices.
Transformations are an important part of any robotic system with multiple frames, so it's important to have a good understanding of it.
This blog lacks the depth for deep understanding of these concepts.
As such, I've provided some references for further readings for the interested readers.

In the next blog, I'll be presenting a data structure that holds transformations among different frames.
So, stay tuned!

## Further readings
The rotation matrices and transformation matrices fall under a special mathematical structure known as a [matrix Lie group](https://en.wikipedia.org/wiki/Lie_group).
Specifically, the rotation matrices fall under the [special orthogonal group](https://en.wikipedia.org/wiki/Lie_group), whereas the transformation matrices fall under the [special Euclidean group](https://en.wikipedia.org/wiki/Euclidean_group).
A very good introduction to Lie groups for robotics is presented by Sola[^4].

For a more thorough and a more solid intro to reference frames, Lie groups, and robotics in general, Barfoot's book is quite something[^5].


# References

[^1]: [Representing Robot Pose: The good, the bad, and the ugly](http://paulfurgale.info/news/2014/6/9/representing-robot-pose-the-good-the-bad-and-the-ugly)
[^2]: [Reducing the uncertainty about the uncertainties, part 2: Frames and manifolds](https://gtsam.org/2021/02/23/uncertainties-part2.html)
[^3]: [Direction Cosine Matrix](https://www.sciencedirect.com/topics/engineering/direction-cosine-matrix)
[^4]: [A micro Lie theory for state estimation in robotics](https://arxiv.org/abs/1812.01537)
[^5]: [State Estimation for Robotics](http://asrl.utias.utoronto.ca/~tdb/bib/barfoot_ser17.pdf)


