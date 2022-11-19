"""Dev Knot Filter Plugin."""
from __future__ import absolute_import, division, print_function

from ansible.errors import AnsibleFilterError


def dev_knot_filter(some_text: str) -> bool:
    """Dev Knot Filter Plugin.

    Some Description

    Args:
        some_text (str): Some String

    Returns:
        bool: True / False
    """
    if not isinstance(some_text, str):
        raise AnsibleFilterError("dev_knot_filter expects a string")


# pylint: disable=too-few-public-methods
class FilterModule:
    """Custom Filter Module Object."""

    @staticmethod
    def filters():
        """Filter."""
        return {"dev_knot_filter": dev_knot_filter}
