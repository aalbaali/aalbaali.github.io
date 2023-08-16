#!/bin/env/python
"""
This script demonstrates the Gauss-Newton algorithm for computing the mean of a set of angles.

Amro Al-Baali
16-Aug-2023
"""

import numpy as np
import math
import matplotlib.pyplot as plt
from collections import namedtuple
from typing import List, Dict

# Collection to store an "experiment"
Experiment = namedtuple('Experiment', ['name', 'angles', 'th0'])
Means: Dict[Experiment, float] = {}

def Exp(angle: float):
    """Unit circle exponential map. Specifically, maps angle to a complex number."""
    return math.cos(angle) + 1j * math.sin(angle)

def Log(z: complex):
    """Unit circle logarithm map. Specifically, maps a (unit) complex number to an angle."""
    return np.angle(z)

def wrap_angle(angle: float):
    """Wraps angle to [-pi, pi]"""
    return Log(Exp(angle))

def heading_diff(z1: complex, z2: complex):
    """Returns the difference between two headings on the unit circle."""
    return Log(z1 * z2.conjugate())

def get_error_vec(angles: List[float], angle: float):
    """Returns the error vector for a given set of angles and a given angle."""
    return [heading_diff(Exp(angle), Exp(a)) for a in angles]

def get_total_squared_error(angles: List[float], angle: float):
    """Returns the total squared error for a given set of angles and a given angle."""
    return 0.5 * np.sum([err * err for err in get_error_vec(angles, angle)])

def compute_mean(angles, th0):
    """Computes the mean of a set of angles using the gradient-descent/Gauss-Newton algorithm."""
    thk = th0
    thkm1 = 1000
    while abs(thk - thkm1) > 1e-6:
        thkm1 = thk
        thk = thkm1 - 0.1 * np.mean([wrap_angle(thkm1 - angle) for angle in angles])
    return thk

def plot_results(experiment: Experiment, show_title: bool = False):
    """Plots the results of an experiment."""
    print(f"Running experiment {experiment.name}")
    angles = experiment.angles
    th0 = experiment.th0

    thetas = np.linspace(-np.pi, np.pi, 1000)
    errors = [get_total_squared_error(angles, theta) for theta in thetas]

    mean = compute_mean(angles, th0)

    # Plot headings
    plt.figure()
    plt.xlabel('x')
    plt.ylabel('y')

    plt.plot(np.cos(thetas), np.sin(thetas), 'k', label='Unit circle')
    head_length = 0.1
    for theta in angles:
        plt.arrow(0, 0, (1 - head_length) * math.cos(theta), (1 - head_length) * math.sin(theta),
                  head_width=0.05, head_length=head_length, fc='b', ec='b')
    plt.arrow(0, 0, (1 - head_length) * math.cos(th0), (1 - head_length) * math.sin(th0),
              head_width=0.05, head_length=head_length, fc='r', ec='r',  label='$\\theta^0$', linestyle='--')
    plt.arrow(0, 0, (1 - head_length) * math.cos(mean), (1 - head_length) * math.sin(mean),
              head_width=0.05, head_length=head_length, fc='g', ec='g', label='$\\bar{\\theta}$', linestyle='-.')

    plt.title(experiment.name if show_title else None)
    plt.axis('equal')
    plt.legend(loc='upper right')


    # Plot objective function vs theta
    plt.figure()
    plt.title(experiment.name if show_title else None)

    plt.plot(thetas, errors)
    plt.axvline(x=th0, color='r', linestyle='--', label='$\\theta^0$')
    plt.axvline(x=mean, color='g', linestyle='-.', label='$\\bar{\\theta}$')

    plt.legend(loc='upper right')
    plt.rc('text', usetex=True)
    plt.xlabel("$\\theta$ [rad]")
    plt.ylabel("Objective function $J(\\theta)$")


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--show-title', action='store_true')
    args = parser.parse_args()
    
    experiments = [
        Experiment('Local minimum', [np.pi/4, 3 / 4 * np.pi], np.pi / 3),
        Experiment('Global minimum', [np.pi/4, 3 / 4 * np.pi], -np.pi / 3),
        Experiment('Multiple global minima 1', [0, 2/3 * np.pi, -2/3*np.pi], np.pi / 3 - 0.1),
        Experiment('Multiple global minima 2', [0, 2/3 * np.pi, -2/3*np.pi], np.pi / 3 + 0.1),
    ]

    for experiment in experiments:
        plot_results(experiment, show_title=args.show_title)

    plt.show()
