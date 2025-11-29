"""Agent Platform runner for the kingdom-monorepo agent registry.

This module loads agent, tool, and crew configurations expressed in JSON and
exposes a lightweight interface that mirrors the payloads expected by the
OpenAI Chat Completions API. It does not send requests; instead, it builds
ready-to-submit payloads that can be used by downstream executors or tests.
"""

from dataclasses import dataclass
from pathlib import Path
import json
from typing import Any, Dict, List, Sequence


@dataclass
class ToolDefinition:
    """Representation of a function-style tool compatible with OpenAI."""

    name: str
    description: str
    parameters: Dict[str, Any]

    @classmethod
    def from_spec(cls, spec: Dict[str, Any]) -> "ToolDefinition":
        function_block = spec["function"]
        return cls(
            name=function_block["name"],
            description=function_block["description"],
            parameters=function_block["parameters"],
        )

    def as_openai_dict(self) -> Dict[str, Any]:
        return {
            "type": "function",
            "function": {
                "name": self.name,
                "description": self.description,
                "parameters": self.parameters,
            },
        }


@dataclass
class AgentDefinition:
    """Declarative definition of an agent role."""

    agent_id: str
    name: str
    model: str
    instructions: str
    tools: Sequence[str]
    style: Dict[str, Any]
    input_schema: Dict[str, Any]

    @classmethod
    def from_spec(cls, spec: Dict[str, Any]) -> "AgentDefinition":
        return cls(
            agent_id=spec["id"],
            name=spec["name"],
            model=spec["model"],
            instructions=spec["instructions"],
            tools=spec.get("tools", ()),
            style=spec.get("style", {}),
            input_schema=spec.get("input_schema", {}),
        )


@dataclass
class CrewDefinition:
    """Grouping of agents into a crew-style workflow."""

    crew_id: str
    name: str
    mission: str
    entry_agent: str
    collaborators: Sequence[str]
    playbook: Sequence[str]
    hand_off: Dict[str, Any]

    @classmethod
    def from_spec(cls, spec: Dict[str, Any]) -> "CrewDefinition":
        return cls(
            crew_id=spec["id"],
            name=spec["name"],
            mission=spec["mission"],
            entry_agent=spec["entry_agent"],
            collaborators=spec.get("collaborators", ()),
            playbook=spec.get("playbook", ()),
            hand_off=spec.get("hand_off", {}),
        )


class AgentPlatform:
    """Utility for loading registries and building OpenAI-compatible payloads."""

    def __init__(self, agent_registry: Path, tool_registry: Path, crew_registry: Path):
        self.agent_registry_path = agent_registry
        self.tool_registry_path = tool_registry
        self.crew_registry_path = crew_registry
        self.tools = self._load_tools()
        self.agents = self._load_agents()
        self.crews = self._load_crews()

    def _load_tools(self) -> Dict[str, ToolDefinition]:
        registry = json.loads(self.tool_registry_path.read_text())
        tool_map = {}
        for spec in registry.get("tools", []):
            tool = ToolDefinition.from_spec(spec)
            tool_map[tool.name] = tool
        return tool_map

    def _load_agents(self) -> Dict[str, AgentDefinition]:
        registry = json.loads(self.agent_registry_path.read_text())
        agent_map = {}
        for spec in registry.get("agents", []):
            agent = AgentDefinition.from_spec(spec)
            agent_map[agent.agent_id] = agent
        return agent_map

    def _load_crews(self) -> Dict[str, CrewDefinition]:
        registry = json.loads(self.crew_registry_path.read_text())
        crew_map = {}
        for spec in registry.get("crews", []):
            crew = CrewDefinition.from_spec(spec)
            crew_map[crew.crew_id] = crew
        return crew_map

    def list_agents(self) -> List[str]:
        return list(self.agents)

    def list_tools(self) -> List[str]:
        return list(self.tools)

    def list_crews(self) -> List[str]:
        return list(self.crews)

    def build_openai_chat_request(self, agent_id: str, user_prompt: str) -> Dict[str, Any]:
        agent = self.agents[agent_id]
        enabled_tools = [self.tools[name].as_openai_dict() for name in agent.tools]
        messages = [
            {"role": "system", "content": agent.instructions},
            {"role": "user", "content": user_prompt},
        ]
        return {
            "model": agent.model,
            "messages": messages,
            "tools": enabled_tools,
            "temperature": 0.3,
        }

    def crew_playbook(self, crew_id: str) -> Dict[str, Any]:
        crew = self.crews[crew_id]
        members = [self.agents[crew.entry_agent]] + [self.agents[mid] for mid in crew.collaborators]
        return {
            "crew_id": crew.crew_id,
            "name": crew.name,
            "mission": crew.mission,
            "entry_agent": crew.entry_agent,
            "collaborators": crew.collaborators,
            "playbook": crew.playbook,
            "hand_off": crew.hand_off,
            "participants": [member.agent_id for member in members],
        }

    def simulate_handshake(self, crew_id: str, objective: str) -> Dict[str, Any]:
        playbook = self.crew_playbook(crew_id)
        entry_agent = self.agents[playbook["entry_agent"]]
        handshake = {
            "objective": objective,
            "entry_agent": entry_agent.agent_id,
            "collaborators": playbook["collaborators"],
            "steps": playbook["playbook"],
            "handoff": playbook["hand_off"],
        }
        return handshake


def load_default_platform() -> AgentPlatform:
    base = Path(__file__).resolve().parent.parent
    return AgentPlatform(
        agent_registry=base / "configs" / "agent_registry.json",
        tool_registry=base / "configs" / "tool_registry.json",
        crew_registry=base / "crews" / "crewai_configs.json",
    )


__all__ = [
    "AgentPlatform",
    "AgentDefinition",
    "ToolDefinition",
    "CrewDefinition",
    "load_default_platform",
]
