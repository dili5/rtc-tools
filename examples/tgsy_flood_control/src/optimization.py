import numpy as np

from rtctools.optimization.collocated_integrated_optimization_problem import (
    CollocatedIntegratedOptimizationProblem,
)
from rtctools.optimization.csv_mixin import CSVMixin
from rtctools.optimization.goal_programming_mixin import Goal, GoalProgrammingMixin
from rtctools.optimization.modelica_mixin import ModelicaMixin
from rtctools.util import run_optimization_problem


class MinimizeStateGoal(Goal):
    """
    Minimize a state/output variable over the full optimization horizon.
    """

    order = 1

    def __init__(self, state, function_nominal, priority):
        self.state = state
        self.function_nominal = function_nominal
        self.priority = priority

    def function(self, optimization_problem, ensemble_member):
        del ensemble_member
        return optimization_problem.state(self.state)


class SmoothControlGoal(Goal):
    order = 2

    def __init__(self, control_state, function_nominal, priority):
        self.control_state = control_state
        self.function_nominal = function_nominal
        self.priority = priority

    def function(self, optimization_problem, ensemble_member):
        del ensemble_member
        return optimization_problem.der(self.control_state)


class TgsyOptimization(
    GoalProgrammingMixin,
    CSVMixin,
    ModelicaMixin,
    CollocatedIntegratedOptimizationProblem,
):
    """
    Real-time flood dispatch optimization on top of tgsy.mo.

    Primary objectives:
    1) minimize xixianghe_Q,
    2) minimize shiyan_storage_V,
    3) minimize tiegang_storage_V.
    """

    model_name = "tgsy"
    control_variables = (
        "jiuwei_liantongzha_Q",
        "yingrenshi_xieshuizha_Q",
        "yingrenshi_liantongzha_Q",
        "jiuwei_xieshuizha_Q",
        "tiegang_yihongdao_gate_Q",
        "baoshihu_xieshuizha_Q",
        "baoshihu_yihongdao_Q",
        "shiyan_yihongdaozha_Q",
        "shengyanshengtaiku_yan_Q",
        "shiyan_shengtaiku_xieshuizha_Q",
        "shiyan_gongshui_Q_set",
        "tiegang_gongshui_Q_set",
    )

    def path_goals(self):
        goals = super().path_goals()

        # Priority 10: minimize downstream flood process.
        goals.append(MinimizeStateGoal("xixianghe_Q", function_nominal=100.0, priority=10))

        # Priority 20: minimize storage process at key reservoirs.
        goals.append(MinimizeStateGoal("shiyan_storage_V", function_nominal=1.0e7, priority=20))
        goals.append(MinimizeStateGoal("tiegang_storage_V", function_nominal=1.0e8, priority=20))

        # Priority 30: keep operations smooth.
        for control in self.control_variables:
            goals.append(SmoothControlGoal(control, function_nominal=100.0, priority=30))

        return goals

    def path_constraints(self, ensemble_member):
        """
        Enforce hard operational limits from timeseries_import.csv.
        """
        constraints = super().path_constraints(ensemble_member)

        # Hard flood-discharge limits at receiving rivers.
        constraints.append((self.state("xixianghe_Q"), 0.0, self.get_timeseries("xixianghe_Q_max")))
        constraints.append((self.state("maozhouhe_Q"), 0.0, self.get_timeseries("maozhouhe_Q_max")))

        # Hard storage volume bands for key reservoirs.
        constraints.append(
            (
                self.state("shiyan_storage_V"),
                self.get_timeseries("shiyan_storage_V_min"),
                self.get_timeseries("shiyan_storage_V_max"),
            )
        )
        constraints.append(
            (
                self.state("tiegang_storage_V"),
                self.get_timeseries("tiegang_storage_V_min"),
                self.get_timeseries("tiegang_storage_V_max"),
            )
        )

        # Optional hard lower bounds on municipal water-supply flows.
        constraints.append(
            (self.state("shiyan_gongshui_Q"), self.get_timeseries("shiyan_gongshui_Q_min"), np.inf)
        )
        constraints.append(
            (self.state("tiegang_gongshui_Q"), self.get_timeseries("tiegang_gongshui_Q_min"), np.inf)
        )

        return constraints


if __name__ == "__main__":
    run_optimization_problem(TgsyOptimization)
