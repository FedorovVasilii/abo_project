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

## Plan
1) Segmentation of vessel wall -> width of vessel wall
2) Segmentation of lumen -> width of vessel lumen
3) Calculate WallLumenRatio <img src="https://render.githubusercontent.com/render/math?math={\color{red}\WLR = \frac{\text{vessel wall width}}{\text{vessel lumen width}}}">

## Data
![1](https://user-images.githubusercontent.com/62359460/160247578-4879389b-c6ad-4024-9988-e435eb631c47.png)
![2](https://user-images.githubusercontent.com/62359460/160247579-81d062fc-979a-4de6-9cfe-855bbb4c389b.png)
![3](https://user-images.githubusercontent.com/62359460/160247580-2275af89-70f0-41dc-9bbd-cfcd78a06b88.png)

