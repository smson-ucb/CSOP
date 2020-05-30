# CSOP
Supplementary software - Molecular height measurement by cell surface optical profilometry (CSOP)

Use the following codes to process CSOP images and determine molecular heights.

- CSOP0_segmentation.m: take the confocal z-stack images containing several circles and segment it to z-stacks of individual circles.
- CSOP1_process_stack.m: take a z-stack of an individual circle and determine the radially-averaged fluorescent profile.
- CSOP2_quantify_height.m: take the radially-averaged fluorescent profiles deteremined in CSOP1_process_stack.m and quantify the offset between radii of two fluorscent channels.
