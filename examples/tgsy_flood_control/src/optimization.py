import numpy as np

from rtctools.optimization.collocated_integrated_optimization_problem import (
    CollocatedIntegratedOptimizationProblem,
)
from rtctools.optimization.csv_mixin import CSVMixin
from rtctools.optimization.goal_programming_mixin import Goal, GoalProgrammingMixin, StateGoal
from rtctools.optimization.modelica_mixin import ModelicaMixin
from rtctools.util import run_optimization_problem


class UpperBoundGoal(StateGoal):
    order = 1

    def __init__(self, optimization_problem, state, max_id, function_range, priority):
        self.state = state
        self.target_min = np.nan
        self.target_max = optimization_problem.get_timeseries(max_id)
        self.function_range = function_range
        self.priority = priority
        super().__init__(optimization_problem)


class LowerBoundGoal(StateGoal):
    order = 1

    def __init__(self, optimization_problem, state, min_id, function_range, priority):
        self.state = state
        self.target_min = optimization_problem.get_timeseries(min_id)
        self.target_max = np.nan
        self.function_range = function_range
        self.priority = priority
        super().__init__(optimization_problem)


class StorageBandGoal(StateGoal):
    order = 2

    def __init__(self, optimization_problem, state, function_range, priority):
        self.state = state
        self.target_min = optimization_problem.get_timeseries(f"{state}_min")
        self.target_max = optimization_problem.get_timeseries(f"{state}_max")
        self.function_range = function_range
        self.priority = priority
        super().__init__(optimization_problem)


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
    """

    model_name = "tgsy"

    def path_goals(self):
        goals = super().path_goals()

        # Priority 1: avoid flood risk at external receiving rivers.
        goals.append(
            UpperBoundGoal(
                self,
                state="xixianghe_Q",
                max_id="xixianghe_Q_max",
                function_range=(0.0, 3000.0),
                priority=10,
            )
        )
        goals.append(
            UpperBoundGoal(
                self,
                state="maozhouhe_Q",
                max_id="maozhouhe_Q_max",
                function_range=(0.0, 3000.0),
                priority=10,
            )
        )

        # Priority 2: guarantee municipal supplies as much as possible.
        goals.append(
            LowerBoundGoal(
                self,
                state="shiyan_gongshui_Q",
                min_id="shiyan_gongshui_Q_min",
                function_range=(0.0, 1000.0),
                priority=20,
            )
        )
        goals.append(
            LowerBoundGoal(
                self,
                state="tiegang_gongshui_Q",
                min_id="tiegang_gongshui_Q_min",
                function_range=(0.0, 1000.0),
                priority=20,
            )
        )

        # Priority 3: keep storages inside operating bands.
        for state in (
            "shiyan_shengtaiku_V",
            "baoshihu_shengtaiku_V",
            "yingrenshi_shengtaiku_V",
            "jiuwei_shengtaiku_V",
            "shiyan_storage_V",
            "tiegang_storage_V",
        ):
            goals.append(
                StorageBandGoal(
                    self,
                    state=state,
                    function_range=(0.0, 2.0e8),
                    priority=30,
                )
            )

        # Priority 4: smooth gate trajectories to avoid abrupt operation.
        for control in (
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
        ):
            goals.append(SmoothControlGoal(control, function_nominal=100.0, priority=40))

        return goals


if __name__ == "__main__":
    run_optimization_problem(TgsyOptimization)
