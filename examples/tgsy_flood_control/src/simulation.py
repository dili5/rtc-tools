import logging

from rtctools.simulation.csv_mixin import CSVMixin
from rtctools.simulation.simulation_problem import SimulationProblem
from rtctools.util import run_simulation_problem


class TgsySimulation(CSVMixin, SimulationProblem):
    """
    Flood-process simulation for the tgsy engineering system.

    All input series are read from input/timeseries_import.csv, including
    inflows and gate discharge schedules.
    """

    model_name = "tgsy"


if __name__ == "__main__":
    run_simulation_problem(TgsySimulation, log_level=logging.INFO)
