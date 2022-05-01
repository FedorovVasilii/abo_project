# Project no.17: Vessel wall to lumen ratio determination in adaptive optics retinal images

## Team
- Adriána Špaková
- Klára Sakmárová
- Vasilii Fedorov

## Goal
Design and realize automatic algorithm for vessel wall segmentation. Determine the
vessel wall to lumen ratio. Test the proposed algorithm and evaluate the obtained
results.

## Related papers
[Lumen segmentation in magnetic resonance images](https://www.sciencedirect.com/science/article/pii/S0010482516302827)

[Morphometric analysis of small arteries in the humanretina using adaptive optics imaging](https://www.researchgate.net/publication/259651521_Morphometric_analysis_of_small_arteries_in_the_human_retina_using_adaptive_optics_imaging_Relationship_with_blood_pressure_and_focal_vascular_changes)

[Morphometric analysis of retinal arterioles in control and hypertensive population using adaptive optics imaging](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6786142/)

## Plan
1) Segmentation of vessel wall -> width of vessel wall
2) Segmentation of lumen -> width of vessel lumen
3) Calculate WallLumenRatio <img src="https://render.githubusercontent.com/render/math?math={\color{red}\WLR = \frac{\text{vessel wall width}}{\text{vessel lumen width}}}">

