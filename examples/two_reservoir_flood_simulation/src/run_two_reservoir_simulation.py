import logging

from rtctools.simulation.csv_mixin import CSVMixin
from rtctools.simulation.simulation_problem import SimulationProblem
from rtctools.util import run_simulation_problem

logger = logging.getLogger("rtctools")


class TwoReservoirFloodModel(CSVMixin, SimulationProblem):
    """
    Simulation model for flood routing in a two-reservoir cascade:
      - reservoir A receives local inflow and may spill to B over a weir
      - reservoir A can release through a gated outlet (max 20 m3/s)
      - reservoir B can release to downstream (max 394 m3/s)
      - reservoir B has a supply outlet (max 5 m3/s)
    """

    @staticmethod
    def _clip(value, lower, upper):
        return min(max(value, lower), upper)

    def initialize(self):
        # Initialize commanded inputs for the first step.
        self.set_var("Q_gate_a_cmd", 0.0)
        self.set_var("Q_release_b_cmd", 0.0)
        self.set_var("Q_supply_cmd", 0.0)
        self.set_var("Q_supply_demand", 0.0)
        super().initialize()

    def update(self, dt):
        if dt < 0:
            dt = self.get_time_step()

        # Current states and flows
        level_a = float(self.get_var("level_a"))
        level_b = float(self.get_var("level_b"))
        q_in_b = float(self.get_var("Q_in_b"))
        q_spill_ab = float(self.get_var("Q_spill_ab_out"))
        q_gate_a = float(self.get_var("Q_gate_a_out"))
        q_supply_demand = float(self.get_var("Q_supply_demand"))

        # Controller settings (read from model parameters)
        level_a_target = float(self.get_var("level_a_target"))
        level_b_target = float(self.get_var("level_b_target"))
        kp_gate_a = float(self.get_var("Kp_gate_a"))
        kp_release_b = float(self.get_var("Kp_release_b"))
        kff_release_b = float(self.get_var("Kff_release_b"))

        # Physical constraints
        max_gate_a = float(self.get_var("max_gate_a"))
        max_release_b = float(self.get_var("max_release_b"))
        max_supply_b = float(self.get_var("max_supply_b"))

        # A-gate command: proportional control on reservoir A level.
        q_gate_a_cmd = kp_gate_a * max(level_a - level_a_target, 0.0)
        q_gate_a_cmd = self._clip(q_gate_a_cmd, 0.0, max_gate_a)

        # B-release command: feed-forward incoming flow + level correction.
        incoming_b = q_in_b + q_gate_a + q_spill_ab
        q_release_b_cmd = kff_release_b * incoming_b + kp_release_b * max(
            level_b - level_b_target, 0.0
        )
        q_release_b_cmd = self._clip(q_release_b_cmd, 0.0, max_release_b)

        # B-supply command follows demand but is physically capped.
        q_supply_cmd = self._clip(q_supply_demand, 0.0, max_supply_b)

        self.set_var("Q_gate_a_cmd", q_gate_a_cmd)
        self.set_var("Q_release_b_cmd", q_release_b_cmd)
        self.set_var("Q_supply_cmd", q_supply_cmd)

        logger.debug(
            "Control step t=%.0f s: gateA=%.2f, relB=%.2f, supplyB=%.2f",
            self.get_current_time(),
            q_gate_a_cmd,
            q_release_b_cmd,
            q_supply_cmd,
        )

        super().update(dt)


# Run
run_simulation_problem(TwoReservoirFloodModel, log_level=logging.INFO)
