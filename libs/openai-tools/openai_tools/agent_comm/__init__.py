"""
Agent-to-Agent (A2A) communication tools.

Provides messaging and communication protocols for AI agents to interact
with each other, including message passing, broadcasting, and agent discovery.
"""

import json
import time
from typing import Dict, Any, List, Optional
from datetime import datetime


# In-memory message store (in production, this would be Redis, RabbitMQ, etc.)
_MESSAGE_QUEUES: Dict[str, List[Dict[str, Any]]] = {}
_AGENT_REGISTRY: Dict[str, Dict[str, Any]] = {}
_CHANNELS: Dict[str, List[str]] = {}


def send_message(
    sender_id: str,
    receiver_id: str,
    message: str,
    message_type: str = "text",
    metadata: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Send a message from one agent to another.
    
    Args:
        sender_id: ID of the sending agent
        receiver_id: ID of the receiving agent
        message: The message content
        message_type: Type of message (text, command, data, request, response)
        metadata: Optional metadata dictionary
        
    Returns:
        Success message with message ID
    """
    message_id = f"{sender_id}_{receiver_id}_{int(time.time() * 1000)}"
    
    message_obj = {
        "id": message_id,
        "sender_id": sender_id,
        "receiver_id": receiver_id,
        "message": message,
        "type": message_type,
        "metadata": metadata or {},
        "timestamp": datetime.utcnow().isoformat(),
        "status": "sent",
    }
    
    if receiver_id not in _MESSAGE_QUEUES:
        _MESSAGE_QUEUES[receiver_id] = []
    
    _MESSAGE_QUEUES[receiver_id].append(message_obj)
    
    return f"Message sent with ID: {message_id}"


def receive_message(
    agent_id: str,
    message_type: Optional[str] = None,
    mark_read: bool = True,
) -> List[Dict[str, Any]]:
    """
    Receive messages for an agent.
    
    Args:
        agent_id: ID of the agent receiving messages
        message_type: Optional filter by message type
        mark_read: Whether to mark messages as read (default: True)
        
    Returns:
        List of message dictionaries
    """
    if agent_id not in _MESSAGE_QUEUES:
        return []
    
    messages = _MESSAGE_QUEUES[agent_id]
    
    # Filter by type if specified
    if message_type:
        messages = [m for m in messages if m["type"] == message_type]
    
    # Mark as read if requested
    if mark_read:
        for msg in messages:
            msg["status"] = "read"
    
    return messages


def broadcast_message(
    sender_id: str,
    message: str,
    channel: str = "global",
    message_type: str = "broadcast",
    metadata: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Broadcast a message to all agents in a channel.
    
    Args:
        sender_id: ID of the sending agent
        message: The message content
        channel: Channel to broadcast to (default: global)
        message_type: Type of message (default: broadcast)
        metadata: Optional metadata dictionary
        
    Returns:
        Success message with number of recipients
    """
    if channel not in _CHANNELS:
        return f"Channel {channel} does not exist"
    
    recipients = _CHANNELS[channel]
    
    message_id = f"broadcast_{sender_id}_{channel}_{int(time.time() * 1000)}"
    
    message_obj = {
        "id": message_id,
        "sender_id": sender_id,
        "channel": channel,
        "message": message,
        "type": message_type,
        "metadata": metadata or {},
        "timestamp": datetime.utcnow().isoformat(),
        "status": "sent",
    }
    
    # Send to all recipients
    for recipient_id in recipients:
        if recipient_id != sender_id:  # Don't send to self
            if recipient_id not in _MESSAGE_QUEUES:
                _MESSAGE_QUEUES[recipient_id] = []
            
            recipient_msg = message_obj.copy()
            recipient_msg["receiver_id"] = recipient_id
            _MESSAGE_QUEUES[recipient_id].append(recipient_msg)
    
    return f"Broadcast message to {len(recipients) - 1} agents in channel {channel}"


def register_agent(
    agent_id: str,
    agent_name: str,
    capabilities: List[str],
    metadata: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Register an agent in the agent network.
    
    Args:
        agent_id: Unique ID for the agent
        agent_name: Human-readable name for the agent
        capabilities: List of capabilities the agent provides
        metadata: Optional metadata dictionary
        
    Returns:
        Success message
    """
    _AGENT_REGISTRY[agent_id] = {
        "id": agent_id,
        "name": agent_name,
        "capabilities": capabilities,
        "metadata": metadata or {},
        "registered_at": datetime.utcnow().isoformat(),
        "status": "active",
    }
    
    # Create message queue for new agent
    if agent_id not in _MESSAGE_QUEUES:
        _MESSAGE_QUEUES[agent_id] = []
    
    # Add to global channel by default
    if "global" not in _CHANNELS:
        _CHANNELS["global"] = []
    if agent_id not in _CHANNELS["global"]:
        _CHANNELS["global"].append(agent_id)
    
    return f"Agent {agent_name} registered with ID: {agent_id}"


def unregister_agent(agent_id: str) -> str:
    """
    Unregister an agent from the agent network.
    
    Args:
        agent_id: ID of the agent to unregister
        
    Returns:
        Success message
    """
    if agent_id in _AGENT_REGISTRY:
        del _AGENT_REGISTRY[agent_id]
    
    # Remove from all channels
    for channel in _CHANNELS.values():
        if agent_id in channel:
            channel.remove(agent_id)
    
    return f"Agent {agent_id} unregistered"


def discover_agents(capability: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Discover available agents in the network.
    
    Args:
        capability: Optional capability to filter by
        
    Returns:
        List of agent information dictionaries
    """
    agents = list(_AGENT_REGISTRY.values())
    
    # Filter by capability if specified
    if capability:
        agents = [a for a in agents if capability in a["capabilities"]]
    
    return agents


def create_channel(channel_name: str, members: Optional[List[str]] = None) -> str:
    """
    Create a communication channel.
    
    Args:
        channel_name: Name of the channel to create
        members: Optional initial list of agent IDs to add to the channel
        
    Returns:
        Success message
    """
    if channel_name in _CHANNELS:
        return f"Channel {channel_name} already exists"
    
    _CHANNELS[channel_name] = members or []
    
    return f"Channel {channel_name} created with {len(members or [])} members"


def join_channel(agent_id: str, channel_name: str) -> str:
    """
    Add an agent to a communication channel.
    
    Args:
        agent_id: ID of the agent to add
        channel_name: Name of the channel
        
    Returns:
        Success message
    """
    if channel_name not in _CHANNELS:
        return f"Channel {channel_name} does not exist"
    
    if agent_id not in _CHANNELS[channel_name]:
        _CHANNELS[channel_name].append(agent_id)
        return f"Agent {agent_id} joined channel {channel_name}"
    else:
        return f"Agent {agent_id} is already in channel {channel_name}"


def leave_channel(agent_id: str, channel_name: str) -> str:
    """
    Remove an agent from a communication channel.
    
    Args:
        agent_id: ID of the agent to remove
        channel_name: Name of the channel
        
    Returns:
        Success message
    """
    if channel_name not in _CHANNELS:
        return f"Channel {channel_name} does not exist"
    
    if agent_id in _CHANNELS[channel_name]:
        _CHANNELS[channel_name].remove(agent_id)
        return f"Agent {agent_id} left channel {channel_name}"
    else:
        return f"Agent {agent_id} is not in channel {channel_name}"


def get_agent_status(agent_id: str) -> Dict[str, Any]:
    """
    Get the status and information of an agent.
    
    Args:
        agent_id: ID of the agent
        
    Returns:
        Agent information dictionary
        
    Raises:
        KeyError: If agent not found
    """
    if agent_id not in _AGENT_REGISTRY:
        raise KeyError(f"Agent {agent_id} not found")
    
    agent_info = _AGENT_REGISTRY[agent_id].copy()
    agent_info["unread_messages"] = len(
        [m for m in _MESSAGE_QUEUES.get(agent_id, []) if m["status"] == "sent"]
    )
    
    return agent_info


__all__ = [
    "send_message",
    "receive_message",
    "broadcast_message",
    "register_agent",
    "unregister_agent",
    "discover_agents",
    "create_channel",
    "join_channel",
    "leave_channel",
    "get_agent_status",
]
