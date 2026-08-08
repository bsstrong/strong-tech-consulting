# Carrier Section Navigation in Small Viewports

While reviewing the Carrier detail redesign, we noticed that its left section navigation changes into a horizontal row above the Carrier page title and top action buttons at smaller window widths.

The responsive transformation itself is common, but the resulting hierarchy may not be right for HelixOS: the section navigation appears before the Carrier identity and primary actions. A future Carrier-shell refinement should consider keeping the Carrier title and actions first, then placing compact horizontal section tabs directly beneath that header. At very small widths, horizontally scrollable tabs or a section selector may be more appropriate.

This thought is intentionally not part of the current People & elevations Design C pull request. It should be evaluated separately as a shared Carrier detail layout decision.
